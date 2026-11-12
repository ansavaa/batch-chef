class PagesController < ApplicationController
  def ui_kit
    @catalog_query = params[:q].to_s.strip
    @catalog_recipes = Recipe.published
                             .where("title ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(@catalog_query)}%")
                             .order(created_at: :desc)
                             .limit(4)
    @top_recipes = Recipe.published.order(likes_count: :desc, created_at: :desc).limit(3)
  end
end
