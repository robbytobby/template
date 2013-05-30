class AddFirstNameAndLastNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string, limit: 50
    add_column :users, :last_name, :string, limit: 50
  end
end
