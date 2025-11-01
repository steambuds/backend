module Api
  class HelloController < ApplicationController
    before_action -> { authorize_role!(:admin) }, only: [ :index, :destroy ]

    def index
      render json: Hello.all
    end

    def destroy
      hello = Hello.find(params[:id])
      hello.destroy
      render json: { message: "Hello deleted successfully" }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Hello not found" }, status: :not_found
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
