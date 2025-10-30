class User < ApplicationRecord
  attr_accessor :password

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, 
            format: { 
              with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/,
              message: 'must include at least one lowercase letter, one uppercase letter, and one digit' }
  has_many :refresh_tokens, dependent: :destroy
  enum :role, [:user, :admin]


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
end
