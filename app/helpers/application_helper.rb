module ApplicationHelper
  def recipe_size_details(recipe)
    [
      ("Форма: #{recipe.base_diameter} см" if recipe.base_diameter.present?),
      ("Порции: #{recipe.base_portions}" if recipe.base_portions.present?)
    ].compact.join(" · ")
  end
end
