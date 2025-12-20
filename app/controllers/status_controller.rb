class StatusController < ApplicationController
  def index
    db_status = check_database_status

    render json: {
      status: "ok",
      timestamp: Time.current.iso8601,
      version: SteamBuds::Backend.version,
      revision: SteamBuds::Backend.revision,
      server: {
        environment: Rails.env,
        rails_version: Rails.version,
        ruby_version: RUBY_VERSION
      },
      database: db_status
    }
  rescue => e
    render json: {
      status: "error",
      timestamp: Time.current.iso8601,
      error: e.message,
      database: { connected: false }
    }, status: :service_unavailable
  end

  private

  def check_database_status
    connection = ActiveRecord::Base.connection
    connection.active? # Check if connection is active

    {
      connected: true,
      adapter: connection.adapter_name,
      database: connection.current_database
    }
  rescue => e
    {
      connected: false,
      error: e.message
    }
  end
end
