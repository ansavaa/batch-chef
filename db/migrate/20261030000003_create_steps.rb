class CreateSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :steps do |t|
      t.text :description, null: false
      t.integer :order_index
      t.references :recipe, null: false, foreign_key: true
      t.timestamps
    end
  end
end
