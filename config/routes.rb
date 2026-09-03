Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check
  resources :chats, only: [:index, :show, :create, :destroy] do
    resources :messages, only: [:create]
  end
end
