module Authorizable
  extend ActiveSupport::Concern

  private

  # Authorizes the current user against allowed roles
  # Automatically handles authentication first, then checks authorization
  #
  # @param allowed_roles [Array<String, Symbol>] List of roles that are authorized
  # @raise [Unauthorized] if authentication fails
  # @raise [Forbidden] if current_user does not have any of the allowed roles
  #
  # Usage:
  #   before_action -> { authorize_role!(:admin) }
  #   before_action -> { authorize_role!(:admin, :manager) }
  def authorize_role!(*allowed_roles)
    # First ensure user is authenticated (calls authenticate_request! if needed)
    if current_user.nil?
      authenticate_request!
      # If authentication failed and rendered an error response, stop here
      return unless current_user
    end

    # Convert allowed_roles to strings for consistent comparison
    allowed_roles = allowed_roles.map(&:to_s)

    # Check if user has any of the allowed roles
    has_permission = allowed_roles.any? { |role| current_user.has_role?(role) }

    unless has_permission
      render json: {
        error: "Forbidden",
        message: "You do not have permission to access this resource"
      }, status: :forbidden
      return
    end
  end
end
