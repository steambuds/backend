require 'rails_helper'

RSpec.describe 'POST /api/track_visit', type: :request do
  context 'when tracking a visit' do
    context 'on a day with no previous visits' do
      before do
        DailyVisit.delete_all
        post '/api/track_visit'
      end

      it 'creates a new daily visit record' do
        expect(DailyVisit.count).to eq(1)
        expect(DailyVisit.first.count).to eq(1)
        expect(DailyVisit.first.visit_date).to eq(Date.today)
      end

      it 'returns the new visit count' do
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:created)
        expect(json_response['status']).to eq('success')
        expect(json_response['visit_date']).to eq(Date.today.to_s)
        expect(json_response['count']).to eq(1)
      end
    end

    context 'on a day with existing visits' do
      let!(:daily_visit) { DailyVisit.create!(visit_date: Date.today, count: 10) }

      before { post '/api/track_visit' }

      it 'increments the visit count' do
        expect(daily_visit.reload.count).to eq(11)
      end

      it 'does not create a new record' do
        expect(DailyVisit.count).to eq(1)
      end

      it 'returns the updated visit count' do
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['visit_date']).to eq(Date.today.to_s)
        expect(json_response['count']).to eq(11)
      end
    end
  end
end
