class DailyVisit < ApplicationRecord
  validates :visit_date, presence: true, uniqueness: true

  def self.increment_for_today
    daily_visit = find_or_initialize_by(visit_date: Date.today)
    daily_visit.count = (daily_visit.count || 0) + 1
    daily_visit.save!
    daily_visit
  end
end
