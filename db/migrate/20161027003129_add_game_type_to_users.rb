class AddGameTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :game_type, :string, default: nil
  end
end
