PrivatePractice::Application.routes.draw do
  
  resources :images
  
  resources :sessions, :only => [:create, :destroy]
  
  resources :users do
    member do
      get :roles
      post :update_roles
    end

   collection do
     get :search
   end
  end
  
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

  match '/signup', :to => 'users#new'
  match '/signout', :to => 'sessions#destroy'

  root :to => "pages#homepage"
end
