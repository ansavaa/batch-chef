class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_recipe

  def create
    @comment = @recipe.comments.build(comment_params)
    @comment.user = @current_user

    if @comment.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_comment",
            partial: "comments/form",
            locals: { recipe: @recipe, comment: @recipe.comments.build }
          )
        end
        format.html { redirect_to @recipe, notice: "Комментарий добавлен." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_comment",
            partial: "comments/form",
            locals: { recipe: @recipe, comment: @comment }
          ), status: :unprocessable_entity
        end
        format.html { render "recipes/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def require_login
    return if @current_user

    redirect_to login_path, alert: "Войдите, чтобы комментировать рецепты."
  end
end
