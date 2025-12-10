module Api
  class ProfilesController < ApplicationController
    before_action :authenticate_request!
    before_action -> { authorize_role!(:admin) }, only: [ :index ]
    before_action :set_profile, only: [ :show, :update, :destroy ]
    before_action :authorize_profile_access!, only: [ :show, :update, :destroy ]

    # GET /api/profiles (admin only)
    def index
      profiles = Profile.all
      render json: profiles, status: :ok
    end

    # GET /api/profiles/:id
    def show
      render json: @profile, status: :ok
    end

    # POST /api/profiles
    def create
      if current_user.profile.present?
        return render json: { errors: [ "User has already been taken" ] }, status: :unprocessable_entity
      end

      profile = Profile.new(profile_params)
      profile.id = current_user.id

      if profile.save
        render json: profile, status: :created
      else
        render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/profiles/:id
    def update
      if @profile.update(profile_params)
        render json: @profile, status: :ok
      else
        render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/profiles/:id
    def destroy
      @profile.destroy
      render json: { message: "Profile deleted successfully" }, status: :ok
    end

    private

    def set_profile
      @profile = Profile.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Profile not found" }, status: :not_found
    end

    def authorize_profile_access!
      unless @profile.id == current_user.id || current_user.has_role?(:admin)
        render json: { error: "Forbidden: You can only access your own profile" }, status: :forbidden
      end
    end

    def profile_params
      params.permit(
        :name,
        :steamer_id,
        :father_name,
        :mother_name,
        :gender,
        :bio,
        :avatar_url,
        :alternate_mobile_number,
        :address,
        :date_of_birth,
        teacher_detail: {},
        student_details: {},
        experience: {}
      )
    end
  end
end
