class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.references :source, index: true, foreign_key: true
      t.string :title
      t.string :author
      t.text :summary
      t.date :pubdate
      t.string :image
      t.string :link

      t.timestamps null: false
    end
  end
end
