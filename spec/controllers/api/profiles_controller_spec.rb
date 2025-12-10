require 'rails_helper'

RSpec.describe "Api::Profiles", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, username: "otheruser", email: "other@example.com") }
  let(:admin_user) { create(:user, :admin, username: "admin", email: "admin@example.com") }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:other_token) { JsonWebToken.encode(user_id: other_user.id) }
  let(:admin_token) { JsonWebToken.encode(user_id: admin_user.id) }

  describe "GET /api/profiles" do
    context "with admin role" do
      before do
        create(:profile, :teacher, user: user)
        create(:profile, :student, user: other_user)
      end

      it "returns all profiles" do
        get "/api/profiles", headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.count).to eq(2)
      end

      it "returns profiles with all attributes" do
        get "/api/profiles", headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json.first.keys).to include('id', 'name', 'bio', 'avatar_url')
      end
    end

    context "without admin role" do
      it "returns 403 Forbidden" do
        get "/api/profiles", headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Forbidden')
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        get "/api/profiles"

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Missing token')
      end
    end
  end

  describe "GET /api/profiles/:id" do
    let(:profile) { create(:profile, :teacher, user: user) }
    let(:other_profile) { create(:profile, :student, user: other_user) }

    context "when user owns the profile" do
      it "returns the profile" do
        get "/api/profiles/#{profile.id}", headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(profile.id)
      end
    end

    context "when admin accesses another user's profile" do
      it "returns the profile" do
        get "/api/profiles/#{profile.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(profile.id)
      end
    end

    context "when user tries to access another user's profile" do
      it "returns 403 Forbidden" do
        get "/api/profiles/#{other_profile.id}", headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Forbidden: You can only access your own profile')
      end
    end

    context "when profile does not exist" do
      it "returns 404 Not Found" do
        get "/api/profiles/00000000-0000-0000-0000-000000000000", headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Profile not found')
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        get "/api/profiles/#{profile.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/profiles" do
    context "with valid teacher params" do
      let(:valid_teacher_params) do
        {
          name: "John Teacher",
          bio: "Experienced teacher",
          gender: "male",
          teacher_detail: {
            subjects_taught: "Mathematics, Physics",
            years_experience: 10,
            qualification: "PhD in Mathematics"
          },
          alternate_mobile_number: "+1234567890",
          date_of_birth: "1985-05-15"
        }
      end

      it "creates a teacher profile" do
        expect {
          post "/api/profiles", params: valid_teacher_params, headers: { 'Authorization' => "Bearer #{token}" }
        }.to change(Profile, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('John Teacher')
        expect(json['teacher_detail']['subjects_taught']).to eq('Mathematics, Physics')
        expect(json['id']).to eq(user.id)
      end
    end

    context "with valid student params" do
      let(:valid_student_params) do
        {
          name: "Jane Student",
          bio: "High school student",
          gender: "female",
          student_details: {
            grade_level: "Grade 10",
            enrollment_date: "2023-09-01",
            parent_contact: "+9876543210"
          },
          alternate_mobile_number: "+1234567890"
        }
      end

      it "creates a student profile" do
        expect {
          post "/api/profiles", params: valid_student_params, headers: { 'Authorization' => "Bearer #{token}" }
        }.to change(Profile, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('Jane Student')
        expect(json['student_details']['grade_level']).to eq('Grade 10')
        expect(json['id']).to eq(user.id)
      end
    end

    context "with minimal params" do
      let(:minimal_params) do
        {
          name: "Minimal User"
        }
      end

      it "creates a profile with minimal data" do
        expect {
          post "/api/profiles", params: minimal_params, headers: { 'Authorization' => "Bearer #{token}" }
        }.to change(Profile, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('Minimal User')
      end
    end

    context "with invalid params" do
      it "returns error for invalid alternate_mobile_number format" do
        params = { name: "Test", alternate_mobile_number: "invalid" }
        post "/api/profiles", params: params, headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Alternate mobile number must be a valid phone number (10-15 digits, optional +)")
      end

      it "returns error for future date_of_birth" do
        params = { name: "Test", date_of_birth: Date.tomorrow }
        post "/api/profiles", params: params, headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Date of birth must be less than #{Date.current}")
      end

      it "returns error for invalid gender" do
        params = { name: "Test", gender: "invalid" }
        post "/api/profiles", params: params, headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Gender invalid is not a valid gender")
      end

      it "returns error when user already has a profile" do
        create(:profile, :teacher, user: user)
        params = { name: "Duplicate" }
        post "/api/profiles", params: params, headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("User has already been taken")
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        post "/api/profiles", params: { name: "Test" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/profiles/:id" do
    let(:profile) { create(:profile, :teacher, user: user) }
    let(:other_profile) { create(:profile, :student, user: other_user) }

    context "when user owns the profile" do
      it "updates the profile" do
        patch "/api/profiles/#{profile.id}",
              params: { bio: "Updated bio", name: "Updated Name" },
              headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['bio']).to eq('Updated bio')
        expect(json['name']).to eq('Updated Name')
      end

      it "updates teacher_detail JSONB field" do
        patch "/api/profiles/#{profile.id}",
              params: { teacher_detail: { subjects_taught: "Computer Science", years_experience: "5" } },
              headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['teacher_detail']['subjects_taught']).to eq('Computer Science')
        expect(json['teacher_detail']['years_experience']).to eq("5")
      end

      it "updates only specified fields" do
        original_name = profile.name
        patch "/api/profiles/#{profile.id}",
              params: { bio: "New bio" },
              headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['bio']).to eq('New bio')
        expect(json['name']).to eq(original_name)
      end
    end

    context "when admin updates another user's profile" do
      it "allows the update" do
        patch "/api/profiles/#{profile.id}",
              params: { bio: "Admin updated bio" },
              headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['bio']).to eq('Admin updated bio')
      end
    end

    context "when user tries to update another user's profile" do
      it "returns 403 Forbidden" do
        patch "/api/profiles/#{other_profile.id}",
              params: { bio: "Unauthorized update" },
              headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Forbidden: You can only access your own profile')
      end
    end

    context "with invalid update params" do
      it "returns errors for invalid data" do
        patch "/api/profiles/#{profile.id}",
              params: { alternate_mobile_number: "invalid" },
              headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Alternate mobile number must be a valid phone number (10-15 digits, optional +)")
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        patch "/api/profiles/#{profile.id}", params: { bio: "Test" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/profiles/:id" do
    let(:profile) { create(:profile, :teacher, user: user) }
    let(:other_profile) { create(:profile, :student, user: other_user) }

    context "when user owns the profile" do
      it "deletes the profile" do
        profile_to_delete = create(:profile, :teacher, user: user)
        expect {
          delete "/api/profiles/#{profile_to_delete.id}", headers: { 'Authorization' => "Bearer #{token}" }
        }.to change(Profile, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Profile deleted successfully')
      end
    end

    context "when admin deletes another user's profile" do
      it "allows the deletion" do
        profile_to_delete = create(:profile, :teacher, user: user)
        expect {
          delete "/api/profiles/#{profile_to_delete.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }
        }.to change(Profile, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when user tries to delete another user's profile" do
      it "returns 403 Forbidden" do
        delete "/api/profiles/#{other_profile.id}", headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Forbidden: You can only access your own profile')
      end

      it "does not delete the profile" do
        profile_to_delete = create(:profile, :student, user: other_user)
        expect {
          delete "/api/profiles/#{profile_to_delete.id}", headers: { 'Authorization' => "Bearer #{token}" }
        }.not_to change(Profile, :count)
      end
    end

    context "when profile does not exist" do
      it "returns 404 Not Found" do
        delete "/api/profiles/00000000-0000-0000-0000-000000000000", headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Profile not found')
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        delete "/api/profiles/#{profile.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
