class Profile < ApplicationRecord
  belongs_to :user

  enum :user_type, { teacher: "teacher", student: "student" }, validate: true

  validates :user_id, uniqueness: true
  validates :user_type, presence: true

  # Conditional validations for teacher-specific fields
  validates :subjects_taught, presence: true, if: :teacher?
  validates :years_experience, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true, if: :teacher?

  # Conditional validations for student-specific fields
  validates :grade_level, presence: true, if: :student?
  validates :enrollment_date, presence: true, if: :student?

  # Common field validations
  validates :phone, format: { with: /\A\+?\d{10,15}\z/, message: "must be a valid phone number (10-15 digits, optional +)" }, allow_blank: true
  validates :date_of_birth, comparison: { less_than: Date.current }, allow_blank: true

  def teacher?
    user_type == "teacher"
  end

  def student?
    user_type == "student"
  end
end
