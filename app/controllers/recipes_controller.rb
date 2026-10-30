class RecipesController < ApplicationController
  before_action :require_login, except: :public_index

  def index
    @recipes = @current_user.recipes
  end

  def show
    @recipe = @current_user.recipes.find(params[:id])
    @scaled_ingredients = scaled_ingredients_with_cost
  end

  def public_index
    @recipes = Recipe.all.order(created_at: :desc)
  end

  def new
    @recipe = @current_user.recipes.build
    @recipe.ingredients.build
    @recipe.steps.build
  end

  def create
    @recipe = @current_user.recipes.build(recipe_params)

    if @recipe.save
      redirect_to @recipe
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def require_login
    return if @current_user

    redirect_to login_path, alert: "Войдите, чтобы работать с рецептами."
  end

  def recipe_params
    params.require(:recipe).permit(
      :title,
      :base_diameter,
      :base_portions,
      ingredients_attributes: %i[id name amount unit _destroy],
      steps_attributes: %i[id description is_completed _destroy]
    )
  end

  def scaled_ingredients_with_cost
    if params[:target_diameter].present?
      scaled_ingredients = @recipe.scale_ingredients(:diameter, params[:target_diameter])
    elsif params[:target_portions].present?
      scaled_ingredients = @recipe.scale_ingredients(:portions, params[:target_portions])
    else
      return []
    end

    scaled_ingredients.map do |ingredient|
      amount_kg = amount_in_kilograms(ingredient[:amount], ingredient[:unit])

      ingredient.merge(
        api: IngredientApiService.convert_and_cost(ingredient[:name], amount_kg)
      )
    end
  end

  def amount_in_kilograms(amount, unit)
    case unit.to_s.downcase
    when "g", "г"
      amount.to_f / 1000
    when "kg", "кг"
      amount.to_f
    when "ml", "мл"
      amount.to_f / 1000
    when "l", "л"
      amount.to_f
    else
      amount.to_f
    end
  end
end
