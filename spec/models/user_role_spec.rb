require 'rails_helper'

RSpec.describe UserRole, type: :model do
  describe "associations" do
    it "belongs to a user" do
      user_role = build(:user_role)
      expect(user_role.user).to be_present
    end
  end

  describe "enum" do
    it "defines role enum with admin, server_machine, and manager" do
      expect(UserRole.roles.keys).to match_array(['admin', 'server_machine', 'manager'])
    end

    it "stores role as string in database" do
      expect(UserRole.roles.values).to match_array(['admin', 'server_machine', 'manager'])
    end

    it "allows setting role to admin" do
      user_role = build(:user_role, role: :admin)
      expect(user_role.role).to eq('admin')
      expect(user_role.admin?).to be true
    end

    it "allows setting role to server_machine" do
      user_role = build(:user_role, role: :server_machine)
      expect(user_role.role).to eq('server_machine')
      expect(user_role.server_machine?).to be true
    end

    it "allows setting role to manager" do
      user_role = build(:user_role, role: :manager)
      expect(user_role.role).to eq('manager')
      expect(user_role.manager?).to be true
    end

    it "persists role as string in database" do
      user_role = create(:user_role, role: :admin)
      user_role.reload
      expect(user_role.role).to eq('admin')
      expect(user_role.read_attribute(:role)).to eq('admin')
    end

    it "can query by string role value" do
      admin_role = create(:user_role, role: :admin)
      manager_role = create(:user_role, role: :manager)

      admins = UserRole.where(role: 'admin')
      expect(admins).to include(admin_role)
      expect(admins).not_to include(manager_role)
    end

    it "can use enum scopes" do
      admin_role = create(:user_role, role: :admin)
      manager_role = create(:user_role, role: :manager)

      expect(UserRole.admin).to include(admin_role)
      expect(UserRole.admin).not_to include(manager_role)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      user_role = build(:user_role)
      expect(user_role).to be_valid
    end

    it "is invalid without a user" do
      user_role = build(:user_role, user: nil)
      expect(user_role).not_to be_valid
    end

    it "prevents duplicate role assignment to the same user" do
      user = create(:user)
      create(:user_role, user: user, role: :admin)
      duplicate_role = build(:user_role, user: user, role: :admin)

      expect(duplicate_role).not_to be_valid
      expect(duplicate_role.errors[:role]).to include("has already been assigned to this user")
    end

    it "allows the same role to be assigned to different users" do
      user1 = create(:user)
      user2 = create(:user)
      create(:user_role, user: user1, role: :admin)

      expect(build(:user_role, user: user2, role: :admin)).to be_valid
    end

    it "allows different roles to be assigned to the same user" do
      user = create(:user)
      create(:user_role, user: user, role: :admin)

      expect(build(:user_role, user: user, role: :manager)).to be_valid
    end
  end
end
