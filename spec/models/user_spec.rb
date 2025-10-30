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

  it "is invalid without an email" do
    subject.email = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:email]).to include("can't be blank")
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

  it "authenticates with correct password" do
    user = create(:user, password: "1Securepass")
    expect(user.valid_password?("1Securepass")).to be true
  end

  it "does not authenticate with incorrect password" do
    user = create(:user, password: "1Securepass")
    expect(user.valid_password?("wrongpass")).to be false
  end
end
