require 'rails_helper'

RSpec.describe 'POST /api/refresh', type: :request do
  let(:user) { create(:user) }
  let(:refresh_token) { create(:refresh_token, user: user) }

  context 'with valid refresh token' do
    it 'returns a new access token' do
      post '/api/refresh', params: { refresh_token: refresh_token.token }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['token']).to be_present

      # Verify the token is valid
      decoded = JsonWebToken.decode(json['token'])
      expect(decoded['user_id']).to eq(user.id)
    end
  end

  context 'with invalid refresh token' do
    it 'returns unauthorized error' do
      post '/api/refresh', params: { refresh_token: 'invalid_token' }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid refresh token')
    end
  end

  context 'with expired refresh token' do
    let!(:expired_refresh_token) do
      token = create(:refresh_token, user: user)
      token.update(expires_at: 1.day.ago)
      token
    end

    it 'returns unauthorized error and destroys the token' do
      initial_count = RefreshToken.count

      post '/api/refresh', params: { refresh_token: expired_refresh_token.token }

      expect(RefreshToken.count).to eq(initial_count - 1)
      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Refresh token expired')
    end
  end

  context 'without refresh token parameter' do
    it 'returns unauthorized error' do
      post '/api/refresh'

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid refresh token')
    end
  end
end
