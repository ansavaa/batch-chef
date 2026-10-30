class PagesController < ApplicationController
  def ui_kit
    @recipe = if logged_in?
      current_user.recipes.build
    else
      Recipe.new
    end

    @recipe.ingredients.build
  end
end
