module Api
  class RegistrationsController < ApplicationController
    def create
      # Allowed roles for public registration
      allowed_roles = %w[student teacher guardian other]

      # 1. Validate role inclusion if present
      role = params[:role]
      if !role.is_a?(Array) && !allowed_roles.include?(role)
        return render json: {
          errors: [ "Role '#{role}' is not allowed for registration. Allowed roles: #{allowed_roles.join(', ')}" ]
        }, status: :unprocessable_content
      end

      ActiveRecord::Base.transaction do
        # 2. Create User
        user = User.new(user_params)

        # 3. Assign Role if provided
        if role.present?
          user.add_role(role)
        end
        
        unless user.save
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
          raise ActiveRecord::Rollback
        end


        # 4. Create Profile
        profile = Profile.new(profile_params)
        profile.id = user.id # Set composite PK

        unless profile.save
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_content
          raise ActiveRecord::Rollback
        end

        # 5. Success Response
        render json: {
          id: user.id,
          username: user.username,
          email: user.email,
          roles: user.roles,
          profile: profile
        }, status: :created
      end
    end

    private

    def user_params
      params.permit(:username, :email, :password, :mobile_number)
    end

    def profile_params
      params.permit(:name, :gender, :date_of_birth)
    end
  end
end
