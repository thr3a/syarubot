class AddQuizCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :quiz_count, :integer, default: 0
  end
end
