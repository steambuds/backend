module Api
  class UsersController < ApplicationController
    before_action -> { authorize_role!(:admin) }, except: [ :show ]
    before_action :authenticate_request!, only: [ :show ]
    before_action :set_user, only: [ :show, :add_role, :remove_role, :update_roles ]
    before_action :authorize_user_access!, only: [ :show ]

    # GET /api/users
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

    # GET /api/users/:id
    def show
      render json: user_detail(@user), status: :ok
    end

    # POST /api/users/:id/roles
    def add_role
      role = params[:role]&.to_sym

      unless Role.valid?(role)
        return render json: { error: "Invalid role. Valid roles are: #{Role.values.join(', ')}" },
                     status: :unprocessable_entity
      end

      if @user.has_role?(role)
        return render json: { error: "User already has this role" }, status: :unprocessable_entity
      end

      @user.add_role(role)

      if @user.save
        render json: {
          message: "Role added successfully",
          user: {
            id: @user.id,
            username: @user.username,
            roles: @user.roles
          }
        }, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/users/:id/roles/:role
    def remove_role
      role = params[:role]&.to_sym

      unless @user.has_role?(role)
        return render json: { error: "User does not have this role" }, status: :not_found
      end

      @user.remove_role(role)
      @user.save

      render json: {
        message: "Role removed successfully",
        user: {
          id: @user.id,
          username: @user.username,
          roles: @user.roles
        }
      }, status: :ok
    end

    # PUT /api/users/:id/roles
    def update_roles
      # Ensure roles param is present
      unless params.has_key?(:roles)
        return render json: { error: "Roles parameter is required" }, status: :unprocessable_entity
      end

      # Convert to array, handling both array and string inputs, and filter out empty strings
      roles = params[:roles].is_a?(Array) ? params[:roles] : Array(params[:roles])
      roles = roles.reject(&:blank?).map(&:to_sym)

      # Validate all roles (skip validation if empty array)
      if roles.any?
        invalid_roles = roles.reject { |role| Role.valid?(role) }
        if invalid_roles.any?
          return render json: {
            error: "Invalid roles: #{invalid_roles.join(', ')}",
            valid_roles: Role.values
          }, status: :unprocessable_entity
        end
      end

      # Set new roles (this replaces all existing roles)
      @user.roles = roles

      if @user.save
        render json: {
          message: "Roles updated successfully",
          user: {
            id: @user.id,
            username: @user.username,
            roles: @user.roles
          }
        }, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :not_found
    end

    def authorize_user_access!
      # Allow if user is admin OR accessing their own data
      unless current_user.has_role?(:admin) || current_user.id == @user.id
        render json: { error: "Forbidden: You can only access your own user data" }, status: :forbidden
      end
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
      # Filter users who have the specified role in their roles array
      users.where("? = ANY(roles)", params[:role].to_s)
    end

    def filter_by_profile_type(users)
      # Check roll_specific_detail JSONB for teacher or student keys
      case params[:profile_type]
      when "teacher"
        users.joins(:profile).where("profiles.roll_specific_detail ? 'teacher'").distinct
      when "student"
        users.joins(:profile).where("profiles.roll_specific_detail ? 'student'").distinct
      else
        users.joins(:profile).distinct
      end
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
        name: profile.name,
        bio: profile.bio
      }
    end

    def profile_full(profile)
      {
        id: profile.id,
        name: profile.name,
        steamer_id: profile.steamer_id,
        father_name: profile.father_name,
        mother_name: profile.mother_name,
        gender: profile.gender,
        bio: profile.bio,
        avatar_url: profile.avatar_url,
        alternate_mobile_number: profile.alternate_mobile_number,
        address: profile.address,
        date_of_birth: profile.date_of_birth,
        roll_specific_detail: profile.roll_specific_detail,
        experience: profile.experience
      }
    end
  end
end
