class Hello < ApplicationRecord
  MOBILE_NUMBER_REGEX = /\A\+?\d{10,15}\z/

  validates :name, :description, :category, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :mobile_number, format: { with: MOBILE_NUMBER_REGEX, message: "must be a valid mobile number (10-15 digits, optional +)" }, allow_blank: true
  validate :email_or_mobile_present

  private

  def email_or_mobile_present
    if email.blank? && mobile_number.blank?
      errors.add(:base, "Either email or mobile number must be present")
    end
  end
end
