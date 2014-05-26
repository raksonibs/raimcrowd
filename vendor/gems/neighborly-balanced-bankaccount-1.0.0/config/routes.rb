Neighborly::Balanced::Bankaccount::Engine.routes.draw do
  resources :payments, only: %i(new create)
  resources :accounts, only: %i(new create)
  resources :confirmations, only: %i(new create)
  resources :routing_numbers, only: :show
end
