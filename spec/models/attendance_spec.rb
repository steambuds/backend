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

  describe 'PaperTrail' do
    let(:group) { create(:group) }
    let(:student) { create(:user, roles: [:student]) }
    let(:teacher) { create(:user, roles: [:instructor]) }
    let(:attendance) { create(:attendance, group: group, user: student) }

    it 'creates a version on create' do
      expect {
        create(:attendance, group: group, user: student)
      }.to change { PaperTrail::Version.count }.by(1)
    end

    it 'creates a version on update' do
      attendance # ensure created

      expect {
        attendance.update!(status: :late)
      }.to change { attendance.versions.count }.by(1)
    end

    it 'creates a version on destroy' do
      attendance # ensure created

      expect {
        attendance.destroy
      }.to change { PaperTrail::Version.count }.by(1)
    end

    it 'tracks status changes' do
      attendance.update!(status: :late)

      version = attendance.versions.last
      expect(version.changeset).to include("status")
      expect(version.changeset["status"]).to be_present
    end

    it 'records whodunnit for attendance marking' do
      new_attendance = nil
      PaperTrail.request(whodunnit: teacher.id) do
        new_attendance = create(:attendance, group: group, user: student, status: :present)
      end

      expect(new_attendance.versions.last.whodunnit).to eq(teacher.id.to_s)
    end

    it 'tracks multiple status changes' do
      attendance.update!(status: :late)
      attendance.update!(status: :excused)
      attendance.update!(status: :present)

      expect(attendance.versions.count).to be >= 3
      expect(attendance.versions.pluck(:event)).to include("update")
    end

    it 'allows querying attendance history' do
      PaperTrail.request(whodunnit: teacher.id) do
        5.times do |i|
          create(:attendance, group: group, user: student, attendance_at: Date.today - i.days)
        end
      end

      teacher_attendances = PaperTrail::Version.where(whodunnit: teacher.id, item_type: 'Attendance')
      expect(teacher_attendances.count).to be >= 5
    end

    it 'can revert to previous status' do
      original_status = attendance.status
      attendance.update!(status: :late)
      attendance.update!(status: :absent)

      # Get the version before the last update
      previous_version = attendance.versions[-2]
      reverted = previous_version.reify

      expect(reverted.status).to eq("late")
    end
  end
end
