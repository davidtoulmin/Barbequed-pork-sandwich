class ChangeDateFormatInArticles < ActiveRecord::Migration
  def up
    change_column :articles, :pubdate, :datetime
  end

  def down
    change_column :articles, :pubdate, :date
  end
end
