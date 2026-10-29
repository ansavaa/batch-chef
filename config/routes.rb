Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/signup", to: "registrations#new", as: :signup
  post "/signup", to: "registrations#create"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  resources :recipes
  get "/ui", to: "pages#ui_kit", as: :ui_kit

  root "pages#ui_kit"
end
