class Attendance < ApplicationRecord
  belongs_to :group
  belongs_to :user

  enum :status, { present: 0, absent: 1, late: 2, excused: 3 }, validate: true

  validates :attendance_at, presence: true
end
