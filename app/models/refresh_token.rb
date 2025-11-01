class RefreshToken < ApplicationRecord
  belongs_to :user
  before_validation :set_token_and_expiry, if: -> { token.blank? }
  validates :token, presence: true, uniqueness: true

  def expired?
    expires_at < Time.current
  end

  private

  def set_token_and_expiry
    self.token = SecureRandom.hex(32)
    self.expires_at = 30.days.from_now
  end
end
