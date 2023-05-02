Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :users, only: [:create, :show] do
    resources :accounts, only: [:index] do
      resources :account_transactions, only: [:index, :create]
      post :fund
      post :transfer
    end
  end
end
