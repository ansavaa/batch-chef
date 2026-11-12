class LikesController < ApplicationController
  before_action :require_login
  before_action :set_recipe
  before_action :require_public_recipe

  def toggle
    like = @recipe.likes.find_by(user: @current_user)

    if like
      like.destroy!
      @liked = false
    else
      @recipe.likes.create!(user: @current_user)
      @liked = true
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @recipe, notice: @liked ? "Рецепт добавлен в понравившиеся." : "Рецепт убран из понравившихся." }
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def require_login
    return if @current_user

    redirect_to login_path, alert: "Войдите, чтобы оценивать рецепты."
  end

  def require_public_recipe
    return if @recipe.published?

    redirect_to @recipe, alert: "Ставить лайки можно только опубликованным рецептам."
  end
end
