require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "ingredient@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @recipe = Recipe.create!(user: @user, title: "Тестовый рецепт")
  end

  test "ingredient is invalid without amount" do
    ingredient = @recipe.ingredients.build(name: "Мука", unit: "г")

    assert_not ingredient.valid?
    assert_includes ingredient.errors[:amount], "can't be blank"
  end
end
