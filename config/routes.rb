PrivatePractice::Application.routes.draw do
  resources :images
  
  resources :user_sessions, :only => [:new,:create,:destroy]

  resources :bookings, :except => [:edit,:update,:show] do
    collection do
      put :index
    end
  end
  
  resources :appointments do
    member do
      get :unbook
    end

    collection do
      put :index
    end
  end

  resources :users do
    member do
      get :roles
      post :update_roles
    end

   collection do
     get :autocomplete
     get :refresh
     post :search
     post :delete_selected
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
  match '/signin', :to => 'user_sessions#new'
  match '/signout', :to => 'user_sessions#destroy'

  root :to => "pages#homepage"
end
