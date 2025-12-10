require 'rails_helper'

RSpec.describe "Api::Admin::Users", type: :request do
  let(:admin_user) { create(:user, :admin, username: "admin", email: "admin@example.com") }
  let(:regular_user) { create(:user, username: "regular", email: "regular@example.com") }
  let(:instructor_user) { create(:user, username: "instructor", email: "instructor@example.com", roles: [:instructor]) }
  let(:admin_token) { JsonWebToken.encode(user_id: admin_user.id) }
  let(:regular_token) { JsonWebToken.encode(user_id: regular_user.id) }

  describe "GET /api/admin/users" do
    context "with admin role" do
      before do
        create(:profile, :teacher, user: admin_user)
        create(:profile, :student, user: regular_user)
      end

      it "returns all users with profiles and roles" do
        get "/api/admin/users", headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['users']).to be_an(Array)
        expect(json['users'].count).to be >= 2
      end

      it "returns users with correct structure" do
        get "/api/admin/users", headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        first_user = json['users'].first
        expect(first_user.keys).to include('id', 'username', 'email', 'mobile_number', 'created_at', 'roles', 'profile')
      end

      it "includes pagination metadata" do
        get "/api/admin/users", headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json['pagination']).to include('current_page', 'per_page', 'total_pages', 'total_count')
      end

      it "returns users with their roles" do
        get "/api/admin/users", headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        admin = json['users'].find { |u| u['username'] == 'admin' }
        expect(admin['roles']).to include('admin')
      end
    end

    context "with search parameter" do
      let!(:search_user) { create(:user, username: "searchable", email: "search@example.com", mobile_number: "+1234567890") }

      it "finds users by email" do
        get "/api/admin/users", params: { search: "search@" }, headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        usernames = json['users'].map { |u| u['username'] }
        expect(usernames).to include('searchable')
      end

      it "finds users by phone number" do
        get "/api/admin/users", params: { search: "1234567" }, headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        usernames = json['users'].map { |u| u['username'] }
        expect(usernames).to include('searchable')
      end

      it "performs case-insensitive search" do
        get "/api/admin/users", params: { search: "SEARCH@" }, headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        usernames = json['users'].map { |u| u['username'] }
        expect(usernames).to include('searchable')
      end
    end

    context "with role filter" do
      it "filters users by admin role" do
        get "/api/admin/users", params: { role: "admin" }, headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        usernames = json['users'].map { |u| u['username'] }
        expect(usernames).to include('admin')
        expect(usernames).not_to include('regular')
      end
    end


    context "with pagination" do
      before do
        # Create additional users to test pagination
        5.times do |i|
          create(:user, username: "user#{i}", email: "user#{i}@example.com")
        end
      end

      it "respects per_page parameter" do
        get "/api/admin/users", params: { per_page: 2 }, headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json['users'].count).to eq(2)
        expect(json['pagination']['per_page']).to eq(2)
      end

      it "respects page parameter" do
        get "/api/admin/users", params: { page: 2, per_page: 2 }, headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json['pagination']['current_page']).to eq(2)
      end

      it "limits per_page to maximum of 100" do
        get "/api/admin/users", params: { per_page: 200 }, headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json['pagination']['per_page']).to eq(100)
      end

      it "defaults to page 1 and per_page 20" do
        get "/api/admin/users", headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json['pagination']['current_page']).to eq(1)
        expect(json['pagination']['per_page']).to eq(20)
      end
    end

    context "without admin role" do
      it "returns 403 Forbidden" do
        get "/api/admin/users", headers: { 'Authorization' => "Bearer #{regular_token}" }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Forbidden')
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        get "/api/admin/users"

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Missing token')
      end
    end
  end

  describe "GET /api/admin/users/:id" do
    context "with admin role" do
      before do
        create(:profile, :teacher, user: regular_user)
      end

      it "returns detailed user information" do
        get "/api/admin/users/#{regular_user.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(regular_user.id)
        expect(json['username']).to eq('regular')
      end

      it "includes full profile information" do
        get "/api/admin/users/#{regular_user.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json['profile']).to be_present
        expect(json['profile']).to include('name', 'bio', 'teacher_detail', 'student_details', 'experience')
      end

      it "includes all user timestamps" do
        get "/api/admin/users/#{regular_user.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json).to include('created_at', 'updated_at')
      end
    end

    context "when user does not exist" do
      it "returns 404 Not Found" do
        get "/api/admin/users/00000000-0000-0000-0000-000000000000", headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('User not found')
      end
    end

    context "without admin role" do
      it "returns 403 Forbidden" do
        get "/api/admin/users/#{regular_user.id}", headers: { 'Authorization' => "Bearer #{regular_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        get "/api/admin/users/#{regular_user.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/admin/users/:id/roles" do
    context "with admin role" do
      it "adds admin role to user" do
        post "/api/admin/users/#{regular_user.id}/roles",
             params: { role: "admin" },
             headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['roles']).to include('admin')
      end

      it "returns error for invalid role" do
        post "/api/admin/users/#{regular_user.id}/roles",
             params: { role: "invalid_role" },
             headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Invalid role')
      end

      it "returns error when user already has the role" do
        post "/api/admin/users/#{admin_user.id}/roles",
             params: { role: "admin" },
             headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('User already has this role')
      end
    end

    context "without admin role" do
      it "returns 403 Forbidden" do
        post "/api/admin/users/#{regular_user.id}/roles",
             params: { role: "instructor" },
             headers: { 'Authorization' => "Bearer #{regular_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        post "/api/admin/users/#{regular_user.id}/roles", params: { role: "instructor" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/admin/users/:id/roles/:role" do
    context "with admin role" do
      it "removes an existing role from user" do
        delete "/api/admin/users/#{instructor_user.id}/roles/instructor",
               headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Role removed successfully')
        expect(json['user']['roles']).not_to include('instructor')
      end

      it "returns error when user does not have the role" do
        delete "/api/admin/users/#{regular_user.id}/roles/admin",
               headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('User does not have this role')
      end
    end

    context "without admin role" do
      it "returns 403 Forbidden" do
        delete "/api/admin/users/#{instructor_user.id}/roles/instructor",
               headers: { 'Authorization' => "Bearer #{regular_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        delete "/api/admin/users/#{instructor_user.id}/roles/instructor"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /api/admin/users/:id/roles" do
    context "with admin role" do
      it "updates all user roles with valid roles array" do
        put "/api/admin/users/#{regular_user.id}/roles",
            params: { roles: [ "admin", "instructor" ] },
            headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Roles updated successfully')
        expect(json['user']['roles']).to match_array([ 'admin', 'instructor' ])
      end

      it "replaces existing roles" do
        put "/api/admin/users/#{instructor_user.id}/roles",
            params: { roles: [ "admin" ] },
            headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['roles']).to eq([ 'admin' ])
        expect(json['user']['roles']).not_to include('instructor')
      end

      it "allows empty roles array" do
        put "/api/admin/users/#{instructor_user.id}/roles",
            params: { roles: [] },
            headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['roles']).to be_empty
      end

      it "returns error for invalid roles in array" do
        put "/api/admin/users/#{regular_user.id}/roles",
            params: { roles: [ "admin", "invalid_role" ] },
            headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Invalid roles')
        expect(json['valid_roles']).to be_an(Array)
      end

      it "converts string role to array" do
        put "/api/admin/users/#{regular_user.id}/roles",
            params: { roles: "admin" },
            headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['roles']).to eq([ 'admin' ])
      end
    end

    context "without admin role" do
      it "returns 403 Forbidden" do
        put "/api/admin/users/#{regular_user.id}/roles",
            params: { roles: [ "admin" ] },
            headers: { 'Authorization' => "Bearer #{regular_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        put "/api/admin/users/#{regular_user.id}/roles", params: { roles: [ "admin" ] }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
