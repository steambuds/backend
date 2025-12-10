class User < ApplicationRecord
  has_paper_trail

  MOBILE_NUMBER_REGEX = /\A\+?\d{10,15}\z/

  attr_accessor :password

  validates :username, presence: true, uniqueness: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :mobile_number, uniqueness: true, format: { with: MOBILE_NUMBER_REGEX, message: "must be a valid mobile number (10-15 digits, optional +)" }, allow_blank: true
  validates :password, presence: true, length: { minimum: 8 },
            format: {
              with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/,
              message: "must include at least one lowercase letter, one uppercase letter, and one digit" }, on: :create
  validate :email_or_mobile_present
  validate :roles_are_valid

  has_many :refresh_tokens, dependent: :destroy
  has_one :profile, foreign_key: :id, dependent: :destroy
  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users

  # Convert roles array to symbols for consistent usage
  def roles
    (read_attribute(:roles) || []).map(&:to_sym)
  end

  # Override roles= to store as strings in database
  def roles=(values)
    write_attribute(:roles, Array(values).map(&:to_s).uniq)
  end

  # Check if user has a specific role
  def has_role?(role_name)
    roles.include?(role_name.to_sym)
  end

  # Add a role to the user (doesn't save)
  def add_role(role_name)
    role_sym = role_name.to_sym
    return false unless Role.valid?(role_sym)
    return false if has_role?(role_sym)

    self.roles = roles + [ role_sym ]
    true
  end

  # Remove a role from the user (doesn't save)
  def remove_role(role_name)
    role_sym = role_name.to_sym
    return false unless has_role?(role_sym)

    self.roles = roles - [ role_sym ]
    true
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
    return if password.blank?
    self.encrypted_password = BCrypt::Password.create(self.password)
  end

  def email_or_mobile_present
    if email.blank? && mobile_number.blank?
      errors.add(:base, "Either email or mobile number must be present")
    end
  end

  def roles_are_valid
    return if roles.nil? || roles.empty?

    invalid_roles = roles.reject { |role| Role.valid?(role) }
    if invalid_roles.any?
      errors.add(:roles, "contains invalid roles: #{invalid_roles.join(', ')}. Valid roles are: #{Role.values.join(', ')}")
    end
  end
end
