class ApplicationController < ActionController::API
  include Authenticable
  include Authorizable

  before_action :set_paper_trail_whodunnit

  private

  def user_for_paper_trail
    current_user&.id
  end
end
