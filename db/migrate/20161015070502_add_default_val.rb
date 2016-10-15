class AddDefaultVal < ActiveRecord::Migration
  def change
    change_column_default :users, :siritori_cnt, 0
    change_column_default :users, :max_siritori_cnt, 0
    change_column_default :users, :nandoku_cnt, 0
  end
end