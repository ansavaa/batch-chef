class Step < ApplicationRecord
  belongs_to :recipe

  validates :description, presence: true
  validates :is_completed, inclusion: { in: [true, false] }
end
