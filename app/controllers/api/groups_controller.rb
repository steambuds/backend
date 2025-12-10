module Api
  class GroupsController < ApplicationController
    before_action :authenticate_request!

    def index
      groups = current_user.groups
      render json: groups
    end
  end
end
