class Recipe < ApplicationRecord
  scope :published, -> { where(published: true) }

  belongs_to :user

  has_many :ingredients, dependent: :destroy
  has_many :steps, dependent: :destroy
  accepts_nested_attributes_for :ingredients, allow_destroy: true
  accepts_nested_attributes_for :steps, allow_destroy: true

  validates :title, presence: true

  validates :base_diameter,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :base_portions,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true

  def scale_ingredients(target_type, target_value)
    target = target_value.to_f
    ratio = scaling_ratio(target_type, target)

    ingredients.map do |ingredient|
      {
        name: ingredient.name,
        amount: ingredient.amount.to_d * ratio,
        unit: ingredient.unit
      }
    end
  end

  private

  def scaling_ratio(target_type, target_value)
    return 0.to_d if target_value.zero?

    case target_type.to_sym
    when :portions
      return 1.to_d if base_portions.to_f.zero?

      target_value.to_d / base_portions.to_d
    when :diameter
      return 1.to_d if base_diameter.to_f.zero?

      (target_value.to_d**2) / (base_diameter.to_d**2)
    else
      raise ArgumentError, "Unsupported target type: #{target_type.inspect}"
    end
  end
end
