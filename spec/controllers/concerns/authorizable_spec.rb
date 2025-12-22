require "rails_helper"

RSpec.describe Authorizable, type: :controller do
  controller(ApplicationController) do
    before_action -> { authorize_role!(:admin) }, only: [ :admin_only_action ]
    before_action -> { authorize_role!(:admin, :teacher) }, only: [ :multi_role_action ]

    def test_action
      render json: { message: "Success" }
    end

    def admin_only_action
      render json: { message: "Admin access granted" }
    end

    def multi_role_action
      render json: { message: "Multi-role access granted" }
    end
  end

  before do
    routes.draw do
      get "test_action" => "anonymous#test_action"
      get "admin_only_action" => "anonymous#admin_only_action"
      get "multi_role_action" => "anonymous#multi_role_action"
    end
  end

  let(:user) { User.create!(username: "testuser", email: "test@example.com", password: "Password123") }
  let(:admin_user) { User.create!(username: "adminuser", email: "admin@example.com", password: "Password123", roles: [ :admin ]) }
  let(:teacher_user) { User.create!(username: "teacheruser", email: "teacher@example.com", password: "Password123", roles: [ :teacher ]) }

  describe "#authorize_role!" do
    context "when user is not authenticated" do
      it "returns 401 Unauthorized" do
        get :admin_only_action
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Missing token")
      end
    end

    context "when user is authenticated but lacks required role" do
      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "returns 403 Forbidden" do
        get :admin_only_action
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Forbidden")
        expect(json_response["message"]).to eq("You do not have permission to access this resource")
      end
    end

    context "when user has the required role" do
      before do
        allow(controller).to receive(:current_user).and_return(admin_user)
      end

      it "allows access" do
        get :admin_only_action
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Admin access granted")
      end
    end

    context "when multiple roles are allowed" do
      it "allows access if user has admin role" do
        allow(controller).to receive(:current_user).and_return(admin_user)
        get :multi_role_action
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Multi-role access granted")
      end

      it "allows access if user has teacher role" do
        allow(controller).to receive(:current_user).and_return(teacher_user)
        get :multi_role_action
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Multi-role access granted")
      end

      it "denies access if user has neither role" do
        allow(controller).to receive(:current_user).and_return(user)
        get :multi_role_action
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Forbidden")
      end
    end

    context "when roles are passed as strings" do
      before do
        allow(controller).to receive(:current_user).and_return(admin_user)
      end

      it "handles string role names correctly" do
        controller.send(:authorize_role!, "admin")
        expect(response.status).not_to eq(403)
      end
    end

    context "when roles are passed as symbols" do
      before do
        allow(controller).to receive(:current_user).and_return(admin_user)
      end

      it "handles symbol role names correctly" do
        controller.send(:authorize_role!, :admin)
        expect(response.status).not_to eq(403)
      end
    end
  end
end
