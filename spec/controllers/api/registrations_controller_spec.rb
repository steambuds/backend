require 'rails_helper'

RSpec.describe 'POST /api/user', type: :request do
  let(:valid_attributes) do
    {
      username: 'testuser',
      email: 'test@example.com',
      password: 'Password123'
    }
  end

  context 'when the request is valid' do
    before { post '/api/user', params: valid_attributes }

    it 'creates a new user' do
      expect(User.count).to eq(1)
    end

    it 'returns a created status' do
      expect(response).to have_http_status(:created)
    end

    it 'returns the user id, email, and username' do
      json_response = JSON.parse(response.body)
      expect(json_response['email']).to eq('test@example.com')
      expect(json_response['username']).to eq('testuser')
      expect(json_response['id']).not_to be_empty
    end

    it 'does not assign a role by default' do
      expect(User.first.roles).to be_empty
    end
  end

  context 'when the request is invalid' do
    context 'with a duplicate email' do
      before do
        User.create!(valid_attributes)
        post '/api/user', params: valid_attributes
      end

      it 'does not create a new user' do
        expect(User.count).to eq(1)
      end

      it 'returns an unprocessable_content status' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns a validation error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Email has already been taken')
      end
    end

    context 'with a missing parameter' do
      before { post '/api/user', params: { email: 'test@example.com' } }

      it 'returns an unprocessable_content status' do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
