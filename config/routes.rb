Rails.application.routes.draw do
  scope '(:locale)', locale: /pl|en/ do
    root 'home#index'

    resources :sensors, only: [:index, :show, :new, :create]
    resources :measurements, only: [:show]
    resources :readings, only: [:show]
  end
end
