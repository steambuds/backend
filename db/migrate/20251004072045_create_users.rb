# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      ## Database authenticatable
      t.string :username
      t.string :email
      t.string :encrypted_password
      t.string :mobile_number
      t.string :roles, array: true, default: []

      ## Rememberable
      t.datetime :remember_created_at

      ## Audit trail - self-referential foreign keys (nullable)
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :mobile_number  # Non-unique index as per schema design

    # Self-referential foreign keys for audit trail
    add_foreign_key :users, :users, column: :created_by
    add_foreign_key :users, :users, column: :updated_by
  end
end
