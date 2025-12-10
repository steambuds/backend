Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    # Authentication routes
    resources :user, only: [ :create ], controller: "registrations"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"
    post "refresh", to: "refreshes#create"
    resources :hello, only: [ :index, :create, :destroy ]
    resources :profiles
    resources :groups, only: [:index] do
      resources :attendances, only: [:index, :create]
    end

    # Admin routes
    namespace :admin do
      resources :users, only: [ :index, :show ] do
        member do
          post "roles", to: "users#add_role"
          delete "roles/:role", to: "users#remove_role", as: "remove_role"
          put "roles", to: "users#update_roles"
        end
      end
    end
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
