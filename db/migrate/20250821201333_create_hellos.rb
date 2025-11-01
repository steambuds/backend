class CreateHellos < ActiveRecord::Migration[8.0]
  def change
    create_table :hellos, id: :uuid do |t|
      t.string :name
      t.string :email
      t.text :description
      t.string :mobile_number
      t.string :category
      t.timestamps
    end
  end
end
