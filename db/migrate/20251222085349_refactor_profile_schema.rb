class RefactorProfileSchema < ActiveRecord::Migration[8.1]
  def up
    # Change address column to jsonb
    change_column :profiles, :address, :jsonb, using: 'address::jsonb', default: {}
  end

  def down
    # This will lose data if the jsonb was not a simple string.
    change_column :profiles, :address, :text
  end
end
