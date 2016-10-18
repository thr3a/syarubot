class AddNanflagToStations < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection("station").connection
  end
  def change
    add_column :stations, :nandoku_flag, :boolean, default: false
  end
end
