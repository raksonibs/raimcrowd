Rails.application.routes.draw do
  mount Neighborly::Balanced::Creditcard::Engine => '/', as: :neighborly_balanced_creditcard

  resources :projects do
    resources :contributions
  end
end
