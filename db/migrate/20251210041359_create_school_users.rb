# frozen_string_literal: true

class CreateSchoolUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :school_users, id: :uuid do |t|
      t.uuid :school_id, null: false
      t.uuid :user_id, null: false
      t.string :relation, null: false  # instructor, facilitator, student, principal

      # Audit trail
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    # Unique constraint on school_id and user_id combination
    add_index :school_users, [ :school_id, :user_id ], unique: true

    # Foreign keys
    add_foreign_key :school_users, :schools
    add_foreign_key :school_users, :users
    add_foreign_key :school_users, :users, column: :created_by
    add_foreign_key :school_users, :users, column: :updated_by
  end
end
