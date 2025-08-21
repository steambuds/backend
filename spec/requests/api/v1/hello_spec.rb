require 'rails_helper'

RSpec.describe "Api::V1::Hello", type: :request do
  describe "GET /index" do
    before do
      FactoryBot.create_list(:hello, 3)
    end

    it "returns a list of hellos" do
      get "/api/v1/hello"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).count).to eq(3)
    end
  end

  describe "POST /create" do
    let(:valid_params) do
      {
        hello: {
          name: "Test Name",
          email: "test@example.com",
          description: "Test description",
          subject: "Test subject",
          category: "Test category"
        }
      }
    end

    it "creates a new hello" do
      expect {
        post "/api/v1/hello", params: valid_params
      }.to change(Hello, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq("Test Name")
      expect(json["email"]).to eq("test@example.com")
    end
  end
end
