# frozen_string_literal: true

require 'constraint/system'

Rails.application.routes.draw do
  constraints(Constraint::System) do
    health_check_routes

    scope module: :system do
      get '/domain_check', to: 'domains#check'
    end
  end

  scope '/', module: :admin, as: :admin do
    resources :domains
    root to: 'domains#index', as: :home
  end
end
