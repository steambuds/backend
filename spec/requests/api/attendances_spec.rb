require 'rails_helper'

RSpec.describe "Api::Attendances", type: :request do
  let(:user) { create(:user, :instructor) } # The teacher
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:group) { create(:group) }

  before do
    create(:group_user, :instructor, user: user, group: group)
  end

  describe "GET /api/groups/:group_id/attendances" do
    let(:student1) { create(:user, :student) }
    let(:student2) { create(:user, :student) }
    let!(:profile1) { create(:profile, :student, user: student1, name: "Student One", steamer_id: 1001) }
    let!(:profile2) { create(:profile, :student, user: student2, name: "Student Two", steamer_id: 1002) }

    before do
      create(:group_user, :student, user: student1, group: group)
      create(:group_user, :student, user: student2, group: group)

      # Attendance for student 1
      create(:attendance, group: group, user: student1, attendance_at: "2023-01-01", status: "present")
      create(:attendance, group: group, user: student1, attendance_at: "2023-01-02", status: "late")

      # Attendance for student 2
      create(:attendance, group: group, user: student2, attendance_at: "2023-01-01", status: "absent")
    end

    it "returns students with attendance stats and calendar" do
      get "/api/groups/#{group.id}/attendances", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
      
      s1 = json.find { |s| s['user_id'] == student1.id }
      expect(s1).not_to be_nil
      expect(s1['name']).to eq("Student One")
      expect(s1['steamer_id']).to eq(1001)
      expect(s1['stats']['present']).to eq(1)
      expect(s1['stats']['late']).to eq(1)
      expect(s1['calendar']['2023-01-01']).to eq('present')
      expect(s1['calendar']['2023-01-02']).to eq('late')

      s2 = json.find { |s| s['user_id'] == student2.id }
      expect(s2).not_to be_nil
      expect(s2['stats']['absent']).to eq(1)
      expect(s2['calendar']['2023-01-01']).to eq('absent')
    end

    it "returns forbidden if user is not a teacher of the group" do
      other_group = create(:group)
      get "/api/groups/#{other_group.id}/attendances", headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/groups/:group_id/attendances" do
    let(:student1) { create(:user, :student) }
    let(:student2) { create(:user, :student) }

    before do
      create(:group_user, :student, user: student1, group: group)
      create(:group_user, :student, user: student2, group: group)
    end

    let(:date) { "2023-01-03T09:30:00Z" }
    let(:payload) do
      {
        date: date,
        attendances: [
          { user_id: student1.id, status: "present" },
          { user_id: student2.id, status: "late" }
        ]
      }
    end

    it "creates or updates attendance records" do
      post "/api/groups/#{group.id}/attendances", params: payload.to_json, headers: headers.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:ok)
      
      expect(Attendance.where(group: group, attendance_at: date).count).to eq(2)
      expect(Attendance.find_by(group: group, user: student1, attendance_at: date).status).to eq("present")
      expect(Attendance.find_by(group: group, user: student2, attendance_at: date).status).to eq("late")
    end

    it "updates existing attendance" do
      create(:attendance, group: group, user: student1, attendance_at: date, status: "absent")
      
      post "/api/groups/#{group.id}/attendances", params: payload.to_json, headers: headers.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:ok)
      
      expect(Attendance.find_by(group: group, user: student1, attendance_at: date).status).to eq("present")
    end
  end
end
