Rails.application.routes.draw do
  resources :domains
  get "/", to: "domains#index"
end
