# frozen_string_literal: true

class CreateRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :refresh_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :token
      t.datetime :expires_at

      # Audit trail
      t.uuid :created_by
      t.uuid :updated_by

      t.timestamps null: false
    end

    add_index :refresh_tokens, :token

    # Audit trail foreign keys
    add_foreign_key :refresh_tokens, :users, column: :created_by
    add_foreign_key :refresh_tokens, :users, column: :updated_by
  end
end
