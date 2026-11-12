require "test_helper"
require "securerandom"

class RecipesTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  self.use_transactional_tests = false

  self.fixture_table_names = []

  setup do
    @user_a = User.create!(
      email: "user-a-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @user_b = User.create!(
      email: "user-b-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @user_b_recipe = @user_b.recipes.create!(
      title: "Рецепт пользователя B",
      base_diameter: 20,
      base_portions: 10
    )
  end

  test "user creates a recipe successfully" do
    log_in_as(@user_a)
    click_link "Создать рецепт"

    fill_in "Название рецепта", with: "Шоколадный торт"
    fill_in "Диаметр формы, см", with: "20"
    fill_in "Количество порций, шт.", with: "8"
    fill_in "Например, сахар", with: "Сахар"
    fill_in "Количество", with: "200"
    select "г", from: "recipe[ingredients_attributes][0][unit]"
    fill_in "Например, взбейте яйца с сахаром", with: "Смешать ингредиенты"
    click_button "Сохранить рецепт"

    assert Recipe.exists?(title: "Шоколадный торт", user: @user_a)
    assert_text(/рецепт.*сохран/i)
  end

  test "user cannot edit another user's recipe" do
    log_in_as(@user_a)
    visit edit_recipe_path(@user_b_recipe)

    assert_current_path root_path
    assert_text(/доступ.*запрещён|доступ.*запрещен/i)
  end

  test "recipe cannot be saved without a title" do
    log_in_as(@user_a)
    click_link "Создать рецепт"

    fill_in "Диаметр формы, см", with: "20"
    fill_in "Количество порций, шт.", with: "8"
    fill_in "Например, сахар", with: "Сахар"
    fill_in "Количество", with: "200"
    select "г", from: "recipe[ingredients_attributes][0][unit]"
    fill_in "Например, взбейте яйца с сахаром", with: "Смешать ингредиенты"
    click_button "Сохранить рецепт"

    assert_current_path recipes_path
    assert_text(/название.*не может быть пуст|title.*blank/i)
  end

  test "guest is redirected to login when visiting new recipe" do
    visit new_recipe_path

    assert_current_path login_path
  end

  private

  def log_in_as(user)
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Пароль", with: "password"
    click_button "Войти в аккаунт"
    assert_current_path ui_kit_path
  end
end
