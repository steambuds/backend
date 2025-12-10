require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is invalid without a username" do
    subject.username = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:username]).to include("can't be blank")
  end

  it "requires unique username" do
    create(:user, username: subject.username)
    expect(subject).not_to be_valid
    expect(subject.errors[:username]).to include("has already been taken")
  end

  it "is valid without an email if mobile_number is present" do
    subject.email = nil
    subject.mobile_number = "+1234567890"
    expect(subject).to be_valid
  end

  it "is invalid with an invalid email format" do
    subject.email = "invalid_email"
    expect(subject).not_to be_valid
    expect(subject.errors[:email]).to include("is invalid")
  end

  it "is invalid without a password" do
    subject.password = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:password]).to include("can't be blank")
  end

  it "is invalid with a short password" do
    subject.password = "123"
    expect(subject).not_to be_valid
    expect(subject.errors[:password][0]).to include("is too short")
  end

  it "requires unique email" do
    create(:user, email: subject.email)
    expect(subject).not_to be_valid
    expect(subject.errors[:email]).to include("has already been taken")
  end

  it "is valid with mobile_number instead of email" do
    user = build(:user, email: nil, mobile_number: "+1234567890")
    expect(user).to be_valid
  end

  it "is valid with both email and mobile_number" do
    user = build(:user, email: "test@example.com", mobile_number: "+1234567890")
    expect(user).to be_valid
  end

  it "is invalid without both email and mobile_number" do
    user = build(:user, email: nil, mobile_number: nil)
    expect(user).not_to be_valid
    expect(user.errors[:base]).to include("Either email or mobile number must be present")
  end

  it "validates mobile_number format" do
    user = build(:user, email: nil, mobile_number: "invalid")
    expect(user).not_to be_valid
    expect(user.errors[:mobile_number]).to include("must be a valid mobile number (10-15 digits, optional +)")
  end

  it "requires unique mobile_number" do
    create(:user, email: nil, mobile_number: "+1234567890")
    user = build(:user, email: nil, mobile_number: "+1234567890")
    expect(user).not_to be_valid
    expect(user.errors[:mobile_number]).to include("has already been taken")
  end

  it "authenticates with correct password" do
    user = create(:user, password: "1Securepass")
    expect(user.valid_password?("1Securepass")).to be true
  end

  it "does not authenticate with incorrect password" do
    user = create(:user, password: "1Securepass")
    expect(user.valid_password?("wrongpass")).to be false
  end

  describe "associations" do
    it "has many refresh_tokens with dependent destroy" do
      user = create(:user)
      create(:refresh_token, user: user)
      expect { user.destroy }.to change { RefreshToken.count }.by(-1)
    end

    it "has one profile with dependent destroy" do
      user = create(:user)
      profile = Profile.create!(id: user.id, name: "Test User")
      expect { user.destroy }.to change { Profile.count }.by(-1)
    end

    it "has many group_users" do
      association = described_class.reflect_on_association(:group_users)
      expect(association.macro).to eq :has_many
    end

    it "has many groups through group_users" do
      association = described_class.reflect_on_association(:groups)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :group_users
    end
  end

  describe "#roles" do
    let(:user) { create(:user) }

    it "returns an empty array when user has no roles" do
      expect(user.roles).to eq([])
    end

    it "returns roles as symbols" do
      user.roles = [:admin, :instructor]
      user.save
      expect(user.roles).to match_array([:admin, :instructor])
    end

    it "stores roles as strings in database" do
      user.roles = [:admin, :instructor]
      user.save
      expect(user.read_attribute(:roles)).to match_array(["admin", "instructor"])
    end
  end

  describe "#has_role?" do
    let(:user) { create(:user) }

    before do
      user.roles = [:admin]
      user.save
    end

    it "returns true if the user has the role" do
      expect(user.has_role?(:admin)).to be true
    end

    it "returns false if the user does not have the role" do
      expect(user.has_role?(:instructor)).to be false
    end
  end

  describe "#add_role" do
    let(:user) { create(:user) }

    it "adds a role to the user" do
      user.add_role(:admin)
      expect(user.roles).to include(:admin)
    end

    it "does not add duplicate roles" do
      user.add_role(:admin)
      user.add_role(:admin)
      expect(user.roles.count(:admin)).to eq(1)
    end

    it "validates role is in Role enum" do
      result = user.add_role(:invalid_role)
      expect(result).to be false
    end
  end

  describe "#remove_role" do
    let(:user) { create(:user) }

    before do
      user.roles = [:admin, :instructor]
      user.save
    end

    it "removes a role from the user" do
      user.remove_role(:admin)
      expect(user.roles).not_to include(:admin)
      expect(user.roles).to include(:instructor)
    end

    it "returns false if user doesn't have the role" do
      result = user.remove_role(:facilitator)
      expect(result).to be false
    end
  end

  describe "PaperTrail" do
    it "creates a version on create" do
      expect {
        create(:user)
      }.to change { PaperTrail::Version.count }.by(1)
    end

    it "creates a version on update" do
      user = create(:user)

      expect {
        user.update_columns(username: "newusername")
      }.to change { user.versions.count }.by(1)
    end

    it "creates a version on destroy" do
      user = create(:user)

      expect {
        user.destroy
      }.to change { PaperTrail::Version.count }.by(1)
    end

    it "records the changeset" do
      user = create(:user)
      user.update_columns(username: "newusername")

      version = user.versions.last
      expect(version.changeset).to include("username")
      expect(version.changeset["username"]).to eq([user.reload.username, "newusername"].reverse)
    end

    it "tracks role changes" do
      user = create(:user)
      user.update!(roles: [:admin, :instructor])

      version = user.versions.last
      expect(version.changeset).to include("roles")
    end

    it "records whodunnit when user is set" do
      admin = create(:user)

      user = nil
      PaperTrail.request(whodunnit: admin.id) do
        user = create(:user)
      end

      expect(user.versions.last.whodunnit).to eq(admin.id.to_s)
    end
  end
end
