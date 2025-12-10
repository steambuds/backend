class Attendance < ApplicationRecord
  has_paper_trail

  belongs_to :group
  belongs_to :user
  belongs_to :creator, class_name: "User", foreign_key: "created_by", optional: true
  belongs_to :updater, class_name: "User", foreign_key: "updated_by", optional: true

  enum :status, { present: 0, absent: 1, late: 2, excused: 3 }, validate: true

  validates :attendance_at, presence: true
  validates :status, presence: true
end
