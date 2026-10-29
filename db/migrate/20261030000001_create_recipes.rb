class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.float :base_diameter
      t.integer :base_portions
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
