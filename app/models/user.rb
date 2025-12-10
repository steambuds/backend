class User < ApplicationRecord
  MOBILE_NUMBER_REGEX = /\A\+?\d{10,15}\z/

  attr_accessor :password

  validates :username, presence: true, uniqueness: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :mobile_number, uniqueness: true, format: { with: MOBILE_NUMBER_REGEX, message: "must be a valid mobile number (10-15 digits, optional +)" }, allow_blank: true
  validates :password, presence: true, length: { minimum: 8 },
            format: {
              with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/,
              message: "must include at least one lowercase letter, one uppercase letter, and one digit" }
  validate :email_or_mobile_present

  has_many :refresh_tokens, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_one :profile, foreign_key: :id, dependent: :destroy
  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users

  def roles
    user_roles.map(&:role)
  end

  def has_role?(role_name)
    user_roles.exists?(role: role_name)
  end

  # before saving, encrypt password
  before_save :encrypt_password

  # authenticate method
  def authenticate(raw_password)
    BCrypt::Password.new(self.encrypted_password) == raw_password
  end

  def valid_password?(raw_password)
    authenticate(raw_password)
  end

  private
  def encrypt_password
    self.encrypted_password = BCrypt::Password.create(self.password)
  end

  def email_or_mobile_present
    if email.blank? && mobile_number.blank?
      errors.add(:base, "Either email or mobile number must be present")
    end
  end
end
