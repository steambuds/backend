module Authenticable
  extend ActiveSupport::Concern

  private

  def authenticate_request!
    token = extract_token_from_header

    if token.nil?
      render json: { error: "Missing token" }, status: :unauthorized
      return
    end

    decoded_token = JsonWebToken.decode(token)

    if decoded_token.nil?
      render json: { error: "Invalid or expired token" }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: decoded_token["user_id"])

    if @current_user.nil?
      render json: { error: "User not found" }, status: :unauthorized
    end
  end

  def extract_token_from_header
    header = request.headers["Authorization"]
    return nil unless header.present?

    # Expected format: "Bearer <token>"
    header.split(" ").last if header.start_with?("Bearer ")
  end

  def current_user
    @current_user
  end

  # Optional: authenticate if token is present, but don't enforce
  def authenticate_if_present
    token = extract_token_from_header
    return unless token.present?

    decoded_token = JsonWebToken.decode(token)
    return unless decoded_token.present?

    @current_user = User.find_by(id: decoded_token["user_id"])
  end
end
