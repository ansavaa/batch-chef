class AddStageToIngredients < ActiveRecord::Migration[8.1]
  def change
    add_column :ingredients, :stage, :string
  end
end
