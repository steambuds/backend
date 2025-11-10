# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :user_type, null: false

      # Common fields
      t.text :bio
      t.string :avatar_url
      t.string :phone
      t.text :address
      t.date :date_of_birth

      # Teacher-specific fields
      t.text :subjects_taught
      t.integer :years_experience
      t.string :qualification

      # Student-specific fields
      t.string :grade_level
      t.date :enrollment_date
      t.string :parent_contact

      t.timestamps null: false
    end
  end
end
