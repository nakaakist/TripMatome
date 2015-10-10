class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :website
      t.string :url
      t.datetime :datetime

      t.timestamps null: false
    end
  end
end
