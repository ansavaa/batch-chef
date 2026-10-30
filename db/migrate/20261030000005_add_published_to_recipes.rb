class AddPublishedToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :published, :boolean, null: false, default: false
    add_index :recipes, :published
  end
end
