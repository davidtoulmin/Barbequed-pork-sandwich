Rails.application.routes.draw do
  # Root is the unauthenticated path
  root 'sessions#unauth'

  # Sessions URL
  get 'sessions/unauth', as: :login
  post 'sessions/login', as: :signin
  delete 'sessions/logout', as: :logout

  # Resourceful routes for article
  resources :articles, only: [:show, :index]
  get '/get_articles', to: 'articles#refresh', as: 'scrape_article'
  get '/admin/scrape', to: 'articles#refresh'
  get '/interests', to: 'articles#my_interests', as: 'interests'
  # Resourceful routes for user
  resource :user, only: [:create, :new, :update, :destroy, :edit]
  get '/user/new', to: 'users#new', as: 'users'
  post '/user/new', to: 'users#create', as: 'users_new'
  get '/user/destroy', to: 'users#destroy', as: 'users_destroy'
  patch '/user', to: 'users#update', as: 'user_edit'
  get 'sessions/email', as: :email
  get '/admin/email', to: 'users#email', as: :email_admin
  get '/next_page', to: 'articles#next_page', as: 'next_page_route'
end
