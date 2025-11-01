module Api
  class HelloController < ApplicationController
    before_action :authenticate_request!, only: [ :index ]

    def index
      render json: Hello.all
    end
    def create
      hello = Hello.new(hello_params)
      if hello.save
        render json: hello, status: :created
      else
        render json: { errors: hello.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def hello_params
      params.permit(:name, :email, :description, :mobile_number, :category)
    end
  end
end
