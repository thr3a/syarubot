class AddQuizConditionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :quiz_condition, :string, default: nil
  end
end
