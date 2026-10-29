class RecipesController < ApplicationController
  before_action :require_login

  def index
    @recipes = @current_user.recipes
  end

  def show
    @recipe = @current_user.recipes.find(params[:id])
  end

  def new
    @recipe = @current_user.recipes.build
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
    params.require(:recipe).permit(:title, :base_diameter, :base_portions)
  end
end
