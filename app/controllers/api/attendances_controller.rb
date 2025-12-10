module Api
  class AttendancesController < ApplicationController
    before_action :authenticate_request!
    before_action :set_group
    before_action :authorize_group_access!

    def index
      students = @group.users.includes(:profile).where(group_users: { relation: 'student' })
      attendances = Attendance.where(group_id: @group.id, user_id: students.pluck(:id))

      response_data = students.map do |student|
        student_attendances = attendances.select { |a| a.user_id == student.id }
        
        stats = {
          present: student_attendances.count { |a| a.status == 'present' },
          absent: student_attendances.count { |a| a.status == 'absent' },
          late: student_attendances.count { |a| a.status == 'late' },
          excused: student_attendances.count { |a| a.status == 'excused' }
        }

        calendar = student_attendances.each_with_object({}) do |a, hash|
          hash[a.attendance_at.strftime('%Y-%m-%d')] = a.status
        end

        {
          user_id: student.id,
          steamer_id: student.profile&.steamer_id,
          name: student.profile&.name,
          stats: stats,
          calendar: calendar
        }
      end

      render json: response_data
    end

    def create
      attendance_at = DateTime.parse(params[:date])
      attendances_data = params[:attendances]

      ActiveRecord::Base.transaction do
        attendances_data.each do |attendance_data|
          attendance = Attendance.find_or_initialize_by(
            group_id: @group.id,
            user_id: attendance_data[:user_id],
            attendance_at: attendance_at
          )
          attendance.status = attendance_data[:status]
          attendance.save!
        end
      end

      render json: { message: "Attendance recorded" }, status: :ok
    rescue ArgumentError
      render json: { error: "Invalid date format" }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def authorize_group_access!
      # Check if current user is an instructor or facilitator in this group
      is_teacher = @group.group_users.exists?(user: current_user, relation: ['instructor', 'facilitator'])
      render json: { error: 'Forbidden' }, status: :forbidden unless is_teacher
    end
  end
end
