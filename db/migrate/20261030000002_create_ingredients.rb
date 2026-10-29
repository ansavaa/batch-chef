class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.string :unit
      t.references :recipe, null: false, foreign_key: true
      t.timestamps
    end
  end
end
