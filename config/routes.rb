PrivatePractice::Application.routes.draw do
  resources :images
  
  resources :password_resets, :except => :destroy
  
  resources :email_confirmations, :except => [:index,:destroy]
  
  resources :user_sessions, :only => [:new,:create,:destroy]

  resources :bookings, :except => [:edit,:update] do
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
      get :admin
      post :update_admin
      get :contact_info
      get :edit_contact_info
    end

   collection do
     get :autocomplete
     get :refresh
     get :contact
     post :send_message
     post :contact_update
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
  match '/contact', :to => 'users#contact'

  root :to => "pages#homepage"
end
