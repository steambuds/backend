module Api
  class DailyVisitsController < ApplicationController
    def track
      daily_visit = DailyVisit.increment_for_today
      status = daily_visit.count == 1 ? :created : :ok
      render json: {
        status: "success",
        visit_date: daily_visit.visit_date,
        count: daily_visit.count
      }, status: status
    end
  end
end
