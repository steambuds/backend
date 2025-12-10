class SchoolUser < ApplicationRecord
  self.primary_key = [:school_id, :user_id]
  belongs_to :school
  belongs_to :user

  enum :relation, { student: "student", instructor: "instructor", facilitator: "facilitator", principal: "principal" }, validate: true
end
