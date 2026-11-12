class AddCountersToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :views_count, :integer, null: false, default: 0
    add_column :recipes, :likes_count, :integer, null: false, default: 0
  end
end
