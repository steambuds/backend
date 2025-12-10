# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances, id: :uuid do |t|
      t.uuid :group_id, null: false
      t.uuid :user_id, null: false
      t.datetime :attendance_at, null: false

      # Audit trail
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    # Indexes for query performance
    add_index :attendances, :group_id
    add_index :attendances, :user_id
    add_index :attendances, :attendance_at

    # Foreign keys
    add_foreign_key :attendances, :groups
    add_foreign_key :attendances, :users
    add_foreign_key :attendances, :users, column: :created_by
    add_foreign_key :attendances, :users, column: :updated_by
  end
end
