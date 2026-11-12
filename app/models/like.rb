class Like < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  validates :user_id, uniqueness: { scope: :recipe_id }

  after_create :broadcast_like_changes
  after_destroy :broadcast_like_changes

  private

  def broadcast_like_changes
    return unless Recipe.exists?(recipe_id)

    likes_count = Like.where(recipe_id: recipe_id).count
    Recipe.where(id: recipe_id).update_all(likes_count: likes_count)
    updated_recipe = recipe.reload

    Turbo::StreamsChannel.broadcast_update_to(
      updated_recipe,
      target: "recipe_likes",
      partial: "recipes/likes_count",
      locals: { recipe: updated_recipe }
    )
    Turbo::StreamsChannel.broadcast_replace_to(
      "top_recipes",
      target: "top_recipes",
      partial: "recipes/top_recipes"
    )
  end
end
