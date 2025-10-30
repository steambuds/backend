module Api
  class SessionsController < ApplicationController
    def create
      user = User.find_by(email: params[:email])

      if user&.valid_password?(params[:password])
        access_token = JsonWebToken.encode(user_id: user.id)
        refresh_token = user.refresh_tokens.create!
        render json: { token: access_token, refresh_token: refresh_token.token }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    def destroy
      refresh_token = RefreshToken.find_by(token: params[:refresh_token])
      if refresh_token
        refresh_token.destroy
      end
      head :no_content
    end
  end
end
