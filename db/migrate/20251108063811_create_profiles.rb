# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    # Profiles table uses composite PK where profiles.id = users.id (not a separate FK)
    # This creates a one-to-one relationship with guaranteed referential integrity
    create_table :profiles, id: :uuid do |t|
      # Core identity fields
      t.string :name
      t.integer :steamer_id  # Unique identifier for the Steam Buds system
      t.text :bio

      # Family information
      t.string :father_name
      t.string :mother_name

      # Demographics
      t.string :gender
      t.string :avatar_url
      t.text :address
      t.date :date_of_birth

      # JSON fields for flexible teacher/student-specific data
      # instructor_detail: {years_of_experience, qualification, subjects: []}
      # student_details: {grade, section, roll_number, enrollment_date}
      t.jsonb :roll_specific_detail

      # experience: [{type, description, duration, organization}]
      t.jsonb :experience

      # Contact information
      t.string :alternate_mobile_number

      # Audit trail
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    # The profile ID must match a user ID (composite PK relationship)
    add_foreign_key :profiles, :users, column: :id, primary_key: :id

    # Indexes
    add_index :profiles, :steamer_id, unique: true

    # Audit trail foreign keys
    add_foreign_key :profiles, :users, column: :created_by
    add_foreign_key :profiles, :users, column: :updated_by
  end
end
