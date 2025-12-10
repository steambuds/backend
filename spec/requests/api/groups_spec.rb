require 'rails_helper'

RSpec.describe "Api::Groups", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  describe "GET /api/groups" do
    context "when user is authenticated" do
      let!(:group1) { create(:group) }
      let!(:group2) { create(:group) }
      let!(:group3) { create(:group) }

      before do
        # user is instructor in group1
        create(:group_user, :instructor, user: user, group: group1)
        # user is facilitator in group2
        create(:group_user, :facilitator, user: user, group: group2)
        # user is not in group3
      end

      it "returns groups where user is a member" do
        get "/api/groups", headers: headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
        group_ids = json.map { |g| g['id'] }
        expect(group_ids).to include(group1.id, group2.id)
        expect(group_ids).not_to include(group3.id)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/api/groups"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
