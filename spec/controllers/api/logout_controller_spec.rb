require 'rails_helper'

RSpec.describe 'DELETE /api/logout', type: :request do
  let(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'Password123') }
  let!(:refresh_token) { user.refresh_tokens.create! }

  context 'with a valid refresh token' do
    before { delete '/api/logout', params: { refresh_token: refresh_token.token } }

    it 'returns a no_content status' do
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes the refresh token from the database' do
      expect(RefreshToken.find_by(token: refresh_token.token)).to be_nil
    end
  end

  context 'with an invalid or missing refresh token' do
    before { delete '/api/logout', params: { refresh_token: 'invalid_token' } }

    it 'returns a no_content status' do
      # We return no_content regardless to prevent leaking information
      # about which tokens exist in the system.
      expect(response).to have_http_status(:no_content)
    end

    it 'does not delete the existing refresh token' do
      expect(RefreshToken.find_by(token: refresh_token.token)).not_to be_nil
    end
  end
end
