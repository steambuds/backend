# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups, id: :uuid do |t|
      t.string :name, null: false
      t.string :about
      t.string :grades
      t.boolean :same_school, default: false

      # Audit trail
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    # Audit trail foreign keys
    add_foreign_key :groups, :users, column: :created_by
    add_foreign_key :groups, :users, column: :updated_by
  end
end
