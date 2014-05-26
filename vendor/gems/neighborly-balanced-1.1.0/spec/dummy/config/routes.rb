Rails.application.routes.draw do
  mount Neighborly::Balanced::Engine => '/', as: :neighborly_balanced
end
