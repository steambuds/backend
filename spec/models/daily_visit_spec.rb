require 'rails_helper'

RSpec.describe DailyVisit, type: :model do
  subject { described_class.new(visit_date: Date.today, count: 1) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a visit_date' do
      subject.visit_date = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:visit_date]).to include("can't be blank")
    end

    it 'requires visit_date to be unique' do
      described_class.create!(visit_date: Date.today, count: 5)
      expect(subject).not_to be_valid
      expect(subject.errors[:visit_date]).to include("has already been taken")
    end
  end

  describe '.increment_for_today' do
    context 'when a record for today exists' do
      let!(:daily_visit) { described_class.create!(visit_date: Date.today, count: 5) }

      it 'increments the count' do
        expect {
          described_class.increment_for_today
        }.to change { daily_visit.reload.count }.by(1)
      end
    end

    context 'when no record for today exists' do
      before do
        described_class.where(visit_date: Date.today).delete_all
      end

      it 'creates a new record with count 1' do
        expect {
          described_class.increment_for_today
        }.to change(described_class, :count).by(1)

        expect(described_class.last.visit_date).to eq(Date.today)
        expect(described_class.last.count).to eq(1)
      end
    end
  end
end
