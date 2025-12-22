class CreateDailyVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_visits do |t|
      t.date :visit_date
      t.integer :count

      t.timestamps
    end
    add_index :daily_visits, :visit_date, unique: true
  end
end
