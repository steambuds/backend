require 'rails_helper'

RSpec.describe 'POST /api/user', type: :request do
  let(:valid_attributes) do
    {
      username: 'testuser',
      email: 'test@example.com',
      password: 'Password123',
      mobile_number: '+1234567890',
      role: 'student',
      name: 'Test User',
      gender: 'male',
      address: '123 Test Lane',
      date_of_birth: '2000-01-01'
    }
  end

  context 'when the request is valid' do
    before { post '/api/user', params: valid_attributes }

    it 'creates a new user' do
      expect(User.count).to eq(1)
    end

    it 'creates a new profile' do
      expect(Profile.count).to eq(1)
      expect(Profile.first.id).to eq(User.first.id)
      expect(Profile.first.name).to eq('Test User')
      expect(Profile.first.gender).to eq('male')
      expect(Profile.first.address).to eq('123 Test Lane')
      expect(Profile.first.date_of_birth.to_s).to eq('2000-01-01')
    end

    it 'assigns the requested role' do
      expect(User.first.roles).to include(:student)
    end

    it 'assigns mobile number' do
      expect(User.first.mobile_number).to eq('+1234567890')
    end

    it 'returns a created status' do
      expect(response).to have_http_status(:created)
    end

    it 'returns the user id, email, username and role' do
      json_response = JSON.parse(response.body)
      expect(json_response['email']).to eq('test@example.com')
      expect(json_response['username']).to eq('testuser')
      expect(json_response['id']).not_to be_empty
      expect(json_response['roles']).to include('student')
    end
  end

  context 'when role is invalid' do
    let(:invalid_role_attributes) { valid_attributes.merge(role: 'admin') }

    before { post '/api/user', params: invalid_role_attributes }

    it 'does not create a user' do
      expect(User.count).to eq(0)
    end

    it 'returns unprocessable_content status' do
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns an error message' do
      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to include("Role 'admin' is not allowed for registration. Allowed roles: student, teacher, guardian")
    end
  end

  context 'when role is missing' do
    let(:missing_role_attributes) { valid_attributes.except(:role) }

    before { post '/api/user', params: missing_role_attributes }

    it 'returns unprocessable_content status' do
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns an error message' do
      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to include("Role is required")
    end
  end

  context 'when the request is invalid' do
    context 'with a duplicate email' do
      before do
        User.create!(valid_attributes.except(:role, :name, :gender, :address, :date_of_birth))
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
