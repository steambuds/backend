require 'rails_helper'

RSpec.describe 'POST /api/login', type: :request do
  let(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'Password123') }

  context 'with valid credentials' do
    before { post '/api/login', params: { email: user.email, password: 'Password123' } }

    it 'returns a success status' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a JWT and refresh token' do
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('token')
      expect(json_response).to have_key('refresh_token')
      decoded_token = JsonWebToken.decode(json_response['token'])
      expect(decoded_token[:user_id]).to eq(user.id)
    end
  end

  context 'with invalid credentials' do
    context 'when the password is incorrect' do
      before { post '/api/login', params: { email: user.email, password: 'WrongPassword' } }

      it 'returns an unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the email does not exist' do
      before { post '/api/login', params: { email: 'wrong@example.com', password: 'Password123' } }

      it 'returns an unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
