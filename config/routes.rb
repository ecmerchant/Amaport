Rails.application.routes.draw do
  post 'products/regist'
  post 'products/upload'
  get 'products/show'
  post 'products/search'
  post 'products/set_csv'
  get 'products/setup'
  post 'products/setup'
  get 'products/prepare'
  post 'products/prepare'
  root to: 'products#show'

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
    get '/sign_in' => 'devise/sessions#new'
  end

  devise_for :users, :controllers => {
   :registrations => 'users/registrations'
  }

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
