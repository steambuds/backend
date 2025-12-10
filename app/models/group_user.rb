class GroupUser < ApplicationRecord
  belongs_to :group
  belongs_to :user

  enum :relation, { student: "student", instructor: "instructor", facilitator: "facilitator" }, validate: true
end
