module Api
  module V1
    class HelloController < ApplicationController
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
        params.require(:hello).permit(:name, :email, :description, :subject, :category)
      end
    end

  end
end