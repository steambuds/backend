module Api
  class RegistrationsController < ApplicationController
    def create
      # Allowed roles for public registration
      allowed_roles = %w[student teacher guardian]

      # 1. Validate role presence and inclusion
      role = params[:role]
      if role.blank?
        return render json: { errors: ["Role is required"] }, status: :unprocessable_content
      end

      unless allowed_roles.include?(role)
        return render json: {
          errors: ["Role '#{role}' is not allowed for registration. Allowed roles: #{allowed_roles.join(', ')}"]
        }, status: :unprocessable_content
      end

      ActiveRecord::Base.transaction do
        # 2. Create User
        user = User.new(user_params)
        unless user.save
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
          raise ActiveRecord::Rollback
        end

        # 3. Assign Role
        unless user.add_role(role)
          # Should theoretically be caught by validation above, but extra safety
          render json: { errors: ["Failed to assign role"] }, status: :unprocessable_content
          raise ActiveRecord::Rollback
        end
        user.save! # Persist role change

        # 4. Create Profile
        profile = Profile.new(profile_params)
        profile.id = user.id # Set composite PK
        profile.steamer_id = generate_steamer_id

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
      params.permit(:name, :gender, :address, :date_of_birth)
    end

    def generate_steamer_id
      # Simple generation strategy - can be improved later
      # 9000000 + random offset or sequential
      # For now, let's use a random number in a specific range to avoid collisions in dev
      rand(9000000..9999999)
    end
  end
end
