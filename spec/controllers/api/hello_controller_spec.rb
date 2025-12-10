require 'rails_helper'

RSpec.describe "Api::V1::Hello", type: :request do
  describe "GET /index" do
    let(:user) { create(:user) }
    let(:admin_user) { create(:user, :admin, username: "admin", email: "admin@example.com") }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:admin_token) { JsonWebToken.encode(user_id: admin_user.id) }

    context 'with valid JWT token and admin role' do
      before do
        create_list(:hello, 3)
      end

      it "returns a list of hellos" do
        get "/api/hello", headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).count).to eq(3)
      end

      it "returns all hello attributes" do
        hello = create(:hello, name: "Test Name", description: "Test Desc")
        get "/api/hello", headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        hello_json = json.find { |h| h['id'] == hello.id }
        expect(hello_json['name']).to eq('Test Name')
        expect(hello_json['description']).to eq('Test Desc')
      end
    end

    context 'when no hellos exist' do
      it "returns an empty array" do
        get "/api/hello", headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'with valid JWT token but no admin role' do
      it "returns 403 Forbidden" do
        get "/api/hello", headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Forbidden')
        expect(json['message']).to eq('You do not have permission to access this resource')
      end
    end

    context 'without JWT token' do
      it "returns unauthorized" do
        get "/api/hello"

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Missing token')
      end
    end

    context 'with invalid JWT token' do
      it "returns unauthorized" do
        get "/api/hello", headers: { 'Authorization' => 'Bearer invalid_token' }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid or expired token')
      end
    end

    context 'with expired JWT token' do
      let(:expired_token) { JsonWebToken.encode({ user_id: user.id }, 1.hour.ago) }

      it "returns unauthorized" do
        get "/api/hello", headers: { 'Authorization' => "Bearer #{expired_token}" }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid or expired token')
      end
    end

    context 'with malformed Authorization header' do
      it "returns unauthorized when Bearer prefix is missing" do
        get "/api/hello", headers: { 'Authorization' => token }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Missing token')
      end
    end
  end

  describe "POST /create" do
    let(:valid_params) { attributes_for(:hello) }

    context 'with valid params' do
      it "creates a new hello without authentication" do
        expect {
          post "/api/hello", params: valid_params
        }.to change(Hello, :count).by(1)
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq(valid_params[:name])
        expect(json["email"]).to eq(valid_params[:email])
        expect(json["description"]).to eq(valid_params[:description])
        expect(json["mobile_number"]).to eq(valid_params[:mobile_number])
        expect(json["category"]).to eq(valid_params[:category])
      end

      it "does not require JWT token" do
        post "/api/hello", params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "creates hello with only email (no mobile number)" do
        params = valid_params.except(:mobile_number)
        expect {
          post "/api/hello", params: params
        }.to change(Hello, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "creates hello with only mobile number (no email)" do
        params = valid_params.except(:email)
        expect {
          post "/api/hello", params: params
        }.to change(Hello, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it "returns unprocessable_entity when name is missing" do
        params = valid_params.except(:name)
        post "/api/hello", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Name can't be blank")
      end

      it "returns unprocessable_entity when description is missing" do
        params = valid_params.except(:description)
        post "/api/hello", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Description can't be blank")
      end

      it "returns unprocessable_entity when category is missing" do
        params = valid_params.except(:category)
        post "/api/hello", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Category can't be blank")
      end

      it "returns unprocessable_entity when both email and mobile are missing" do
        params = valid_params.except(:email, :mobile_number)
        post "/api/hello", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Either email or mobile number must be present")
      end

      it "returns unprocessable_entity with invalid email format" do
        params = valid_params.merge(email: 'invalid_email')
        post "/api/hello", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Email is invalid")
      end

      it "returns unprocessable_entity with invalid mobile number format" do
        params = valid_params.merge(mobile_number: '123')
        post "/api/hello", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Mobile number must be a valid mobile number (10-15 digits, optional +)")
      end

      it "does not create a hello when validation fails" do
        params = valid_params.except(:name)
        expect {
          post "/api/hello", params: params
        }.not_to change(Hello, :count)
      end
    end

    context 'with edge cases' do
      it "accepts mobile number with + prefix" do
        params = valid_params.merge(mobile_number: '+1234567890')
        expect {
          post "/api/hello", params: params
        }.to change(Hello, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "accepts 10-digit mobile number" do
        params = valid_params.merge(mobile_number: '1234567890')
        expect {
          post "/api/hello", params: params
        }.to change(Hello, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "accepts 15-digit mobile number" do
        params = valid_params.merge(mobile_number: '123456789012345')
        expect {
          post "/api/hello", params: params
        }.to change(Hello, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "rejects mobile number with letters" do
        params = valid_params.merge(mobile_number: '123abc7890')
        post "/api/hello", params: params

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "rejects mobile number with special characters" do
        params = valid_params.merge(mobile_number: '123-456-7890')
        post "/api/hello", params: params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'security - strong parameters' do
      it "ignores unpermitted parameters" do
        params = valid_params.merge(admin: true, role: 'admin', id: 999)
        post "/api/hello", params: params

        expect(response).to have_http_status(:created)
        hello = Hello.last
        expect(hello.attributes.keys).not_to include('admin', 'role')
      end

      it "filters unpermitted nested attributes" do
        params = valid_params.merge(user: { admin: true })
        post "/api/hello", params: params

        expect(response).to have_http_status(:created)
      end
    end

    context 'multiple validations failure' do
      it "returns all validation errors" do
        params = { email: 'invalid_email', mobile_number: '123' }
        post "/api/hello", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_an(Array)
        expect(json['errors'].length).to be >= 3
      end
    end
  end

  describe "DELETE /destroy" do
    let(:hello) { create(:hello) }
    let(:user) { create(:user) }
    let(:admin_user) { create(:user, :admin, username: "admin", email: "admin@example.com") }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:admin_token) { JsonWebToken.encode(user_id: admin_user.id) }

    context 'with admin role' do
      it "deletes the hello" do
        hello_to_delete = create(:hello)
        expect {
          delete "/api/hello/#{hello_to_delete.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }
        }.to change(Hello, :count).by(-1)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Hello deleted successfully')
      end

      it "returns 404 when hello does not exist" do
        delete "/api/hello/00000000-0000-0000-0000-000000000000", headers: { 'Authorization' => "Bearer #{admin_token}" }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Hello not found')
      end
    end

    context 'without admin role' do
      it "returns 403 Forbidden" do
        hello_to_delete = create(:hello)
        delete "/api/hello/#{hello_to_delete.id}", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Forbidden')
        expect(json['message']).to eq('You do not have permission to access this resource')
      end

      it "does not delete the hello" do
        hello_to_delete = create(:hello)
        expect {
          delete "/api/hello/#{hello_to_delete.id}", headers: { 'Authorization' => "Bearer #{token}" }
        }.not_to change(Hello, :count)
      end
    end

    context 'without authentication' do
      it "returns 401 Unauthorized" do
        delete "/api/hello/#{hello.id}"
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Missing token')
      end
    end

    context 'with invalid token' do
      it "returns 401 Unauthorized" do
        delete "/api/hello/#{hello.id}", headers: { 'Authorization' => 'Bearer invalid_token' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
