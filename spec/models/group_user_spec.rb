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

  describe 'enums' do
    it 'defines relation enum' do
      expect(described_class.defined_enums['relation']).to eq({ "student" => "student", "instructor" => "instructor", "facilitator" => "facilitator" })
    end
  end
end
