require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'validations' do
    it 'validates presence of name' do
      group = Group.new(name: nil)
      expect(group).not_to be_valid
      expect(group.errors[:name]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many group_users' do
      association = described_class.reflect_on_association(:group_users)
      expect(association.macro).to eq :has_many
    end

    it 'has many users through group_users' do
      association = described_class.reflect_on_association(:users)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :group_users
    end
  end
end