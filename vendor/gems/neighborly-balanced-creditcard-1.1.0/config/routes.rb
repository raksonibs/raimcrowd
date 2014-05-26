Neighborly::Balanced::Creditcard::Engine.routes.draw do
  resources :payments,      only: %i(new create update)

  resources :notifications, only: :create
end
