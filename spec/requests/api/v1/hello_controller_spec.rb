require 'rails_helper'

RSpec.describe "Api::V1::Hello", type: :request do
  describe "GET /index" do
    before do
      create_list(:hello, 3)
    end

    it "returns a list of hellos" do
      get "/api/v1/hello"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).count).to eq(3)
    end
  end

  describe "POST /create" do
    let(:valid_params)  {attributes_for(:hello)}

    it "creates a new hello" do
      expect {
        post "/api/v1/hello", params: valid_params
      }.to change(Hello, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq(valid_params[:name])
      expect(json["email"]).to eq(valid_params[:email])
      expect(json["description"]).to eq(valid_params[:description])
      expect(json["mobile_number"]).to eq(valid_params[:mobile_number])
      expect(json["category"]).to eq(valid_params[:category])
    end
  end
end
