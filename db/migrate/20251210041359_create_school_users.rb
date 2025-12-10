# frozen_string_literal: true

class CreateSchoolUsers < ActiveRecord::Migration[8.0]
  def up
    # Join table with composite primary key
    create_table :school_users, id: false do |t|
      t.uuid :school_id, null: false
      t.uuid :user_id, null: false
      t.string :relation, null: false  # instructor, facilitator, student, principal

      # Audit trail
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    # Composite primary key
    execute "ALTER TABLE school_users ADD PRIMARY KEY (school_id, user_id);"

    # Unique index (redundant with PK but included as per spec)
    add_index :school_users, [:school_id, :user_id], unique: true

    # Foreign keys
    add_foreign_key :school_users, :schools
    add_foreign_key :school_users, :users
    add_foreign_key :school_users, :users, column: :created_by
    add_foreign_key :school_users, :users, column: :updated_by
  end

  def down
    drop_table :school_users
  end
end
