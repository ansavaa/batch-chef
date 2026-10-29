require 'net/http'
require 'json'

class IngredientApiService
  KG_TO_LB_RATIO = 2.20462

  def self.convert_and_cost(ingredient_name, amount_kg)
    # Математический перевод в фунты (остается у нас, чтобы не тратить лимиты API)
    amount_lb = (amount_kg.to_f * KG_TO_LB_RATIO).round(2)
    
    begin
      api_key = ENV['SPOONACULAR_API_KEY']
      
      # Шаг 1: Ищем ID ингредиента
      search_url = URI("https://api.spoonacular.com/food/ingredients/search?query=#{URI.encode_www_form_component(ingredient_name)}&apiKey=#{api_key}")
      search_response = Net::HTTP.get(search_url)
      search_data = JSON.parse(search_response)
      
      # Если ингредиент найден
      if search_data['results'] && search_data['results'].any?
        ingredient_id = search_data['results'].first['id']
        
        # Шаг 2: Узнаем стоимость по ID
        info_url = URI("https://api.spoonacular.com/food/ingredients/#{ingredient_id}/information?amount=#{amount_kg}&unit=kilograms&apiKey=#{api_key}")
        info_response = Net::HTTP.get(info_url)
        info_data = JSON.parse(info_response)
        
        # Spoonacular обычно возвращает стоимость в центах США (US Cents)
        cost_value = info_data.dig('estimatedCost', 'value') || 0.0
        currency = info_data.dig('estimatedCost', 'unit') || 'Unknown'
        
        {
          amount_lb: amount_lb,
          total_cost: cost_value.to_f.round(2),
          currency: currency
        }
      else
        raise "Ингредиент не найден в базе Spoonacular"
      end

    rescue => e
      # Выводим ошибку в консоль сервера, чтобы ты видела, если что-то сломается
      Rails.logger.error("IngredientApiService Error: #{e.message}")
      
      # Возвращаем безопасные дефолтные значения (Sad Path)
      {
        amount_lb: amount_lb,
        total_cost: 0.0,
        currency: 'Unknown'
      }
    end
  end
end