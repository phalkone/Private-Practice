PrivatePractice::Application.routes.draw do
  resources :users
  resources :images
  resources :sessions, :only => [:create, :destroy]
  resources :pages do
    member do
      get :toggle
      get :down
      get :up
      post :create
    end

    collection do
      put :changelocale
    end
  end

  match '/signout', :to => 'sessions#destroy'

  root :to => "pages#homepage"
end
