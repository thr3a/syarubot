class AddQuizLevelToUsers < ActiveRecord::Migration
  def change
    add_column :users, :quiz_level, :integer, default: 0
  end
end
