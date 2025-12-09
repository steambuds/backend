module Api
  module Admin
    class UsersController < ApplicationController
      before_action -> { authorize_role!(:admin) }
      before_action :set_user, only: [ :show, :add_role, :remove_role, :update_roles ]

      # GET /api/admin/users
      def index
        users = User.all
        users = apply_search(users) if params[:search].present?
        users = apply_filters(users)
        users = users.order(created_at: :desc)

        # Pagination
        page = params[:page]&.to_i || 1
        per_page = [ params[:per_page]&.to_i || 20, 100 ].min # Max 100 per page

        paginated_users = users.limit(per_page).offset((page - 1) * per_page)

        render json: {
          users: paginated_users.map { |user| user_with_details(user) },
          pagination: {
            current_page: page,
            per_page: per_page,
            total_pages: (users.count.to_f / per_page).ceil,
            total_count: users.count
          }
        }, status: :ok
      end

      # GET /api/admin/users/:id
      def show
        render json: user_detail(@user), status: :ok
      end

      # POST /api/admin/users/:id/roles
      def add_role
        role = params[:role]&.to_sym

        unless UserRole.roles.keys.include?(role.to_s)
          return render json: { error: "Invalid role. Valid roles are: #{UserRole.roles.keys.join(', ')}" },
                       status: :unprocessable_entity
        end

        if @user.has_role?(role)
          return render json: { error: "User already has this role" }, status: :unprocessable_entity
        end

        user_role = @user.user_roles.build(role: role)

        if user_role.save
          render json: {
            message: "Role added successfully",
            user: {
              id: @user.id,
              username: @user.username,
              roles: @user.roles
            }
          }, status: :ok
        else
          render json: { errors: user_role.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/admin/users/:id/roles/:role
      def remove_role
        role = params[:role]&.to_sym

        user_role = @user.user_roles.find_by(role: role)

        if user_role.nil?
          return render json: { error: "User does not have this role" }, status: :not_found
        end

        user_role.destroy
        render json: {
          message: "Role removed successfully",
          user: {
            id: @user.id,
            username: @user.username,
            roles: @user.roles
          }
        }, status: :ok
      end

      # PUT /api/admin/users/:id/roles
      def update_roles
        # Ensure roles param is present
        unless params.has_key?(:roles)
          return render json: { error: "Roles parameter is required" }, status: :unprocessable_entity
        end

        # Convert to array, handling both array and string inputs, and filter out empty strings
        roles = params[:roles].is_a?(Array) ? params[:roles] : Array(params[:roles])
        roles = roles.reject(&:blank?)

        # Validate all roles (skip validation if empty array)
        if roles.any?
          invalid_roles = roles.reject { |role| UserRole.roles.keys.include?(role.to_s) }
          if invalid_roles.any?
            return render json: {
              error: "Invalid roles: #{invalid_roles.join(', ')}",
              valid_roles: UserRole.roles.keys
            }, status: :unprocessable_entity
          end
        end

        # Remove all existing roles
        @user.user_roles.destroy_all

        # Add new roles
        roles.each do |role|
          @user.user_roles.create!(role: role.to_sym)
        end

        render json: {
          message: "Roles updated successfully",
          user: {
            id: @user.id,
            username: @user.username,
            roles: @user.reload.roles
          }
        }, status: :ok
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      def apply_search(users)
        search_term = "%#{params[:search]}%"
        users.where("email ILIKE ? OR mobile_number ILIKE ?", search_term, search_term)
      end

      def apply_filters(users)
        users = filter_by_role(users) if params[:role].present?
        users = filter_by_profile_type(users) if params[:profile_type].present?
        users
      end

      def filter_by_role(users)
        users.joins(:user_roles).where(user_roles: { role: params[:role] }).distinct
      end

      def filter_by_profile_type(users)
        users.joins(:profile).where(profiles: { user_type: params[:profile_type] })
      end

      def user_with_details(user)
        {
          id: user.id,
          username: user.username,
          email: user.email,
          mobile_number: user.mobile_number,
          created_at: user.created_at,
          roles: user.roles,
          profile: user.profile ? profile_summary(user.profile) : nil
        }
      end

      def user_detail(user)
        {
          id: user.id,
          username: user.username,
          email: user.email,
          mobile_number: user.mobile_number,
          created_at: user.created_at,
          updated_at: user.updated_at,
          roles: user.roles,
          profile: user.profile ? profile_full(user.profile) : nil
        }
      end

      def profile_summary(profile)
        {
          user_type: profile.user_type,
          bio: profile.bio
        }
      end

      def profile_full(profile)
        base = {
          id: profile.id,
          user_type: profile.user_type,
          bio: profile.bio,
          avatar_url: profile.avatar_url,
          phone: profile.phone,
          address: profile.address,
          date_of_birth: profile.date_of_birth
        }

        if profile.teacher?
          base.merge({
            subjects_taught: profile.subjects_taught,
            years_experience: profile.years_experience,
            qualification: profile.qualification
          })
        else
          base.merge({
            grade_level: profile.grade_level,
            enrollment_date: profile.enrollment_date,
            parent_contact: profile.parent_contact
          })
        end
      end
    end
  end
end
