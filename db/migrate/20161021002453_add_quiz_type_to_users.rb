class AddQuizTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :quiz_type, :string, default: nil
  end
end
