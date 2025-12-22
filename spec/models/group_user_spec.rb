require 'rails_helper'

RSpec.describe GroupUser, type: :model do
  describe 'associations' do
    it 'belongs to group' do
      association = described_class.reflect_on_association(:group)
      expect(association.macro).to eq :belongs_to
    end

    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'validations' do
    let(:group) { create(:group) }
    let(:student) { create(:user, roles: [ :student ]) }

    it 'validates relation is a valid role' do
      group_user = GroupUser.new(group: group, user: student, relation: "student")
      expect(group_user).to be_valid
    end

    it 'rejects invalid relation' do
      group_user = GroupUser.new(group: group, user: student, relation: "invalid_role")
      expect(group_user).not_to be_valid
      expect(group_user.errors[:relation]).to be_present
    end

    it 'requires user to have the role' do
      teacher_user = create(:user, roles: [ :teacher ])
      group_user = GroupUser.new(group: group, user: teacher_user, relation: "student")
      expect(group_user).not_to be_valid
      expect(group_user.errors[:base]).to include("User must have the 'student' role to be assigned as student in a group")
    end
  end
end
