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
      date_of_birth: '2000-01-01'
    }
  end

  context 'when the request is valid' do
    context 'with all fields' do
      before { post '/api/user', params: valid_attributes }

      it 'creates a new user' do
        expect(User.count).to eq(1)
      end

      it 'creates a new profile with null address and steamer_id' do
        expect(Profile.count).to eq(1)
        profile = Profile.first
        expect(profile.id).to eq(User.first.id)
        expect(profile.name).to eq('Test User')
        expect(profile.gender).to eq('male')
        expect(profile.address).to eq({})
        expect(profile.steamer_id).to be_nil
        expect(profile.date_of_birth.to_s).to eq('2000-01-01')
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

      it 'returns the user and profile data, including nil steamer_id' do
        json_response = JSON.parse(response.body)
        expect(json_response['email']).to eq('test@example.com')
        expect(json_response['username']).to eq('testuser')
        expect(json_response['id']).not_to be_empty
        expect(json_response['roles']).to include('student')
        expect(json_response['profile']['address']).to eq({})
        expect(json_response['profile']['steamer_id']).to be_nil
      end
    end

    context 'with a nullable username' do
      let(:no_username_attributes) { valid_attributes.except(:username) }
      before { post '/api/user', params: no_username_attributes }

      it 'creates a user with a nil username' do
        expect(User.count).to eq(1)
        expect(User.first.username).to be_nil
      end
    end

    context 'without a role' do
      let(:no_role_attributes) { valid_attributes.except(:role) }
      before { post '/api/user', params: no_role_attributes }

      it 'creates a user with an empty roles array' do
        expect(User.count).to eq(1)
        expect(User.first.roles).to be_empty
      end

      it 'returns a created status' do
        expect(response).to have_http_status(:created)
      end
    end
  end

  context 'when role is invalid' do
    let(:invalid_role_attributes) { valid_attributes.merge(role: 'admin') }

    before { post '/api/user', params: invalid_role_attributes }

    it 'does not create a user or profile' do
      expect(User.count).to eq(0)
      expect(Profile.count).to eq(0)
    end

    it 'returns unprocessable_content status' do
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns an error message' do
      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to include("Role 'admin' is not allowed for registration. Allowed roles: student, teacher, guardian")
    end
  end

  context 'when the request is invalid' do
    context 'with a duplicate email' do
      before do
        User.create!(username: 'olduser', email: 'test@example.com', password: 'Password123')
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

    context 'with a missing required parameter like name' do
      before { post '/api/user', params: valid_attributes.except(:name) }

      it 'returns an unprocessable_content status' do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
