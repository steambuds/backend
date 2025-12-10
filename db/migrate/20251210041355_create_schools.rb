# frozen_string_literal: true

class CreateSchools < ActiveRecord::Migration[8.0]
  def change
    create_table :schools, id: :uuid do |t|
      t.integer :steamer_id, null: false
      t.string :school_name, null: false
      t.string :district, null: false
      t.string :city_village
      t.integer :pincode
      t.string :landmark
      t.string :address

      # Audit trail
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    # Indexes
    add_index :schools, :steamer_id, unique: true

    # Audit trail foreign keys
    add_foreign_key :schools, :users, column: :created_by
    add_foreign_key :schools, :users, column: :updated_by
  end
end
