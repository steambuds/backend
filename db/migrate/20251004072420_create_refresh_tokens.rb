class CreateRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :refresh_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
    add_index :refresh_tokens, :token
  end
end
