# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  post 'webhooks/yumoney', to: 'webhooks#yumoney'

  resources :tariff_files, only: %i[new index create destroy] do
    post :create_wg, on: :collection
  end
  resources :tariffs, only: %i[index new create edit update destroy]
  resources :users, only: %i[index show]
  resources :orders, only: %i[index show]

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  root 'tariffs#index'
end
