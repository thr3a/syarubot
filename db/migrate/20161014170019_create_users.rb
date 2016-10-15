class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: false do |t|
      t.string :id, null: false
      t.string :scname
      t.string :name
      t.boolean :weather_flag
      t.string :siritori_word
      t.integer :siritori_cnt
      t.integer :nandoku_cnt
      t.integer :station_id

      t.timestamps null: false
    end
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
  end
end
