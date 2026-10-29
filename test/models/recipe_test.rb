require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "cook@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @recipe = Recipe.create!(
      user: @user,
      title: "Клубничный торт",
      base_diameter: 18,
      base_portions: 12
    )
    @recipe.ingredients.create!(name: "Сахар", amount: 200, unit: "г")
  end

  test "valid recipe is valid" do
    assert @recipe.valid?
  end

  test "recipe is invalid without title" do
    @recipe.title = nil

    assert_not @recipe.valid?
    assert_includes @recipe.errors[:title], "can't be blank"
  end

  test "recipe is invalid with negative diameter" do
    @recipe.base_diameter = -1

    assert_not @recipe.valid?
    assert @recipe.errors[:base_diameter].any?
  end

  test "scales ingredients by portions" do
    result = @recipe.scale_ingredients(:portions, 24)

    assert_equal 400.to_d, result.first[:amount]
  end

  test "scales ingredients by diameter area" do
    result = @recipe.scale_ingredients(:diameter, 20)
    expected = 200.to_d * ((20.to_d**2) / (18.to_d**2))

    assert_in_delta expected.to_f, result.first[:amount].to_f, 0.0001
  end

  test "target diameter of zero produces zero amount" do
    result = @recipe.scale_ingredients(:diameter, 0)

    assert_equal 0.to_d, result.first[:amount]
  end
end
