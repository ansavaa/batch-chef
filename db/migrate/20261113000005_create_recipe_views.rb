class CreateRecipeViews < ActiveRecord::Migration[8.1]
  def change
    create_table :recipe_views do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :recipe_views, %i[recipe_id user_id], unique: true
  end
end
