# frozen_string_literal: true

class CreateUserRoles < ActiveRecord::Migration[8.0]
  def up
    # Create table without default id column - we'll use composite PK
    create_table :user_roles, id: false do |t|
      t.uuid :user_id, null: false
      t.string :role, null: false

      # Audit trail
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    # Add composite primary key on [user_id, role]
    # This ensures one user can't have the same role twice
    execute "ALTER TABLE user_roles ADD PRIMARY KEY (user_id, role);"

    # Unique index (redundant with PK but kept for clarity)
    add_index :user_roles, [ :user_id, :role ], unique: true

    # Foreign keys
    add_foreign_key :user_roles, :users
    add_foreign_key :user_roles, :users, column: :created_by
    add_foreign_key :user_roles, :users, column: :updated_by
  end

  def down
    drop_table :user_roles
  end
end
