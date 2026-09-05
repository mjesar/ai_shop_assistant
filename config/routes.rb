Rails.application.routes.draw do

  mount MissionControl::Jobs::Engine, at: "/jobs"
  get "up" => "rails/health#show", as: :rails_health_check
  resources :chats, only: [:index, :new, :show, :create, :destroy] do
    resources :messages, only: [:create]
  end
end
