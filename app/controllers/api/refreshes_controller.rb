module Api
  class RefreshesController < ApplicationController
    def create
      refresh_token = RefreshToken.find_by(token: params[:refresh_token])

      if refresh_token.nil?
        render json: { error: "Invalid refresh token" }, status: :unauthorized
        return
      end

      if refresh_token.expired?
        refresh_token.destroy
        render json: { error: "Refresh token expired" }, status: :unauthorized
        return
      end

      # Generate new access token
      access_token = JsonWebToken.encode(user_id: refresh_token.user_id)

      render json: { token: access_token }, status: :ok
    end
  end
end
