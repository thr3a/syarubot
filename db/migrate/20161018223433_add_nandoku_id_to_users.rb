class AddNandokuIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nandoku_id, :integer, default: nil
  end
end
