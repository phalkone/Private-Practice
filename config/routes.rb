PrivatePractice::Application.routes.draw do
  resources :images
  
  resources :sessions, :only => [:new,:create,:destroy]

  resources :bookings do
    collection do
      put :index
    end
  end
  
  resources :appointments do
    collection do
      put :refresh
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
  match '/signin', :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  root :to => "pages#homepage"
end
