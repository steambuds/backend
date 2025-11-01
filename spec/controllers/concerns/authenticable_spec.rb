require 'rails_helper'

RSpec.describe Authenticable, type: :controller do
  controller(ApplicationController) do
    before_action :authenticate_request!

    def index
      render json: { message: 'Success', user_id: current_user.id }
    end
  end

  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  describe '#authenticate_request!' do
    context 'with valid token' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
      end

      it 'authenticates and returns success with user_id' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user_id']).to eq(user.id)
        expect(json['message']).to eq('Success')
      end
    end

    context 'without token' do
      before { get :index }

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Missing token')
      end
    end

    context 'with invalid token' do
      before do
        request.headers['Authorization'] = 'Bearer invalid_token'
        get :index
      end

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid or expired token')
      end
    end

    context 'with expired token' do
      let(:expired_token) { JsonWebToken.encode({ user_id: user.id }, 1.hour.ago) }

      before do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        get :index
      end

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid or expired token')
      end
    end

    context 'with token for non-existent user' do
      let(:non_existent_user_token) { JsonWebToken.encode(user_id: 'non-existent-uuid') }

      before do
        request.headers['Authorization'] = "Bearer #{non_existent_user_token}"
        get :index
      end

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('User not found')
      end
    end
  end
end
