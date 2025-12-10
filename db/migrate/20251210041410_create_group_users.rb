# frozen_string_literal: true

class CreateGroupUsers < ActiveRecord::Migration[8.0]
  def up
    # Join table with composite primary key
    create_table :group_users, id: false do |t|
      t.uuid :group_id, null: false
      t.uuid :user_id, null: false
      t.string :relation, null: false  # student, instructor, facilitator

      # Audit trail
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    # Composite primary key
    execute "ALTER TABLE group_users ADD PRIMARY KEY (group_id, user_id);"

    # Indexes
    add_index :group_users, [ :group_id, :user_id ], unique: true
    add_index :group_users, :group_id
    add_index :group_users, :user_id

    # Foreign keys
    add_foreign_key :group_users, :groups
    add_foreign_key :group_users, :users
    add_foreign_key :group_users, :users, column: :created_by
    add_foreign_key :group_users, :users, column: :updated_by
  end

  def down
    drop_table :group_users
  end
end
