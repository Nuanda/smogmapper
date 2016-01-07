Rails.application.routes.draw do
  scope '(:locale)', locale: /pl|en/ do
    root 'home#index'

    resources :sensors, only: [:index, :show]
    resources :measurements, only: [:show]
    resources :readings, only: [:create]
  end
end
