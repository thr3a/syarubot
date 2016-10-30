class AddgamesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :game_count, :integer, default: 0
    add_column :users, :game_conditon, :string, default: nil
    add_column :users, :game_pass_count, :integer, default: 0
  end
end
