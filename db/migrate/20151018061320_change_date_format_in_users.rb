class ChangeDateFormatInUsers < ActiveRecord::Migration
  def up
    change_column :users, :last_emailed, :datetime
  end

  def down
    change_column :users, :last_emailed, :date
  end
end
