class AddViewsMaxToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :views_max, :integer
  end
end
