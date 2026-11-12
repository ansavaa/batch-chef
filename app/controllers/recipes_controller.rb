class RecipesController < ApplicationController
  before_action :require_login, except: %i[public_index show]
  before_action :set_recipe, only: %i[edit update]
  before_action :authorize_recipe!, only: %i[edit update]

  def index
    @recipes = @current_user.recipes
  end

  def show
    @recipe = Recipe.find(params[:id])
    unless @recipe.published? || (@current_user && @recipe.user_id == @current_user.id)
      redirect_to root_path, alert: "Этот рецепт ещё не опубликован."
      return
    end

    record_recipe_view
    @scaled_ingredients = scaled_ingredients_with_cost
    @liked = @current_user && @recipe.likes.exists?(user: @current_user)
  end

  def public_index
    @query = params[:q].to_s.strip
    @recipes = Recipe.published
                    .where("title ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%")
                    .order(created_at: :desc)
  end

  def toggle_publication
    @recipe = @current_user.recipes.find(params[:id])
    @recipe.update!(published: !@recipe.published?)

    status = @recipe.published? ? "опубликован" : "снят с публикации"
    redirect_to recipes_path, notice: "Рецепт «#{@recipe.title}» #{status}."
  end

  def new
    @recipe = @current_user.recipes.build
    @recipe.ingredients.build
    @recipe.steps.build
  end

  def create
    @recipe = @current_user.recipes.build(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: "Рецепт «#{@recipe.title}» сохранён."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Рецепт «#{@recipe.title}» обновлён."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def record_recipe_view
    return unless @current_user

    RecipeView.create!(recipe: @recipe, user: @current_user)
    @recipe.increment!(:views_count)
    Turbo::StreamsChannel.broadcast_update_to(
      @recipe,
      target: "recipe_views",
      partial: "recipes/views_count",
      locals: { recipe: @recipe }
    )
  rescue ActiveRecord::RecordNotUnique
    # The unique database index prevents duplicate views for one user and recipe.
  end

  def authorize_recipe!
    return if @recipe.user_id == @current_user.id

    redirect_to root_path, alert: "Доступ к этому рецепту запрещён."
  end

  def require_login
    return if @current_user

    redirect_to login_path, alert: "Войдите, чтобы работать с рецептами."
  end

  def recipe_params
    params.require(:recipe).permit(
      :title,
      :base_diameter,
      :base_portions,
      :photo,
      ingredients_attributes: %i[id name amount unit stage _destroy],
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
