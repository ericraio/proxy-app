# frozen_string_literal: true

require 'constraint/system'

Rails.application.routes.draw do
  constraints(Constraint::System) do
    health_check_routes

    scope module: :system do
      get '/domain_check', to: 'domains#check'
    end
  end

  resources :domains
  get '/', to: 'domains#index'
end
