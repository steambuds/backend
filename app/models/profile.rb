class Profile < ApplicationRecord
  has_paper_trail

  self.primary_key = :id
  belongs_to :user, foreign_key: :id

  validates :name, presence: true
  validates :steamer_id, uniqueness: true, allow_nil: true
  validates :alternate_mobile_number, format: { with: /\A\+?\d{10,15}\z/, message: "must be a valid phone number (10-15 digits, optional +)" }, allow_blank: true
  validates :date_of_birth, comparison: { less_than: Date.current }, allow_blank: true
  validates :gender, inclusion: { in: %w[male female other], message: "%{value} is not a valid gender" }, allow_blank: true

  # JSONB field default initializers
  attribute :roll_specific_detail, :jsonb, default: {}
  attribute :experience, :jsonb, default: {}
end
