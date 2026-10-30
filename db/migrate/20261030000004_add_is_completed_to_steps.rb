class AddIsCompletedToSteps < ActiveRecord::Migration[8.1]
  def change
    add_column :steps, :is_completed, :boolean, null: false, default: false
  end
end
