class CreateUserRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_roles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role, null: false

      t.timestamps
    end

    add_index :user_roles, [:user_id, :role], unique: true
  end
end
