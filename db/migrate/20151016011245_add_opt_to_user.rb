class AddOptToUser < ActiveRecord::Migration
  def change
    add_column :users, :opt_in, :boolean
  end
end
