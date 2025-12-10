require 'rails_helper'

RSpec.describe Attendance, type: :model do
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
    it 'defines status enum' do
      expect(described_class.defined_enums['status']).to eq({ "present" => 0, "absent" => 1, "late" => 2, "excused" => 3 })
    end
  end

  describe 'validations' do
    it 'validates presence of attendance_at' do
      attendance = Attendance.new(attendance_at: nil)
      attendance.valid?
      expect(attendance.errors[:attendance_at]).to include("can't be blank")
    end
  end
end
