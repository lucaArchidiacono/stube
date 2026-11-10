Rails.application.routes.draw do
  root "homes#show"

  resource :setup, only: %i[new create]
  get "join(/:code)" => "joins#show", as: :join
  post "join/:code" => "joins#create"

  resource :household, only: %i[show update] do
    resource :membership, only: :destroy
  end
  resources :members, only: %i[show update destroy] do
    resources :device_links, only: :create
  end
  resources :devices, only: %i[show update destroy]
  resources :invites, only: %i[create show destroy]

  get "shopping" => "shopping_items#index", as: :shopping
  resources :shopping_items, path: "shopping/items", only: %i[create update destroy] do
    scope module: :shopping_items do
      resource :check_off, only: :create
      resource :position, only: :update
    end
  end
  get "shopping/history" => "shopping_events#index", as: :shopping_history
  resources :shopping_events, path: "shopping/history", only: [] do
    resource :put_back, only: :create, module: :shopping_events
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
