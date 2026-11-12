class Comment < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  validates :body, presence: true

  broadcasts_to ->(comment) { [comment.recipe, :comments] }, inserts_by: :prepend
end
