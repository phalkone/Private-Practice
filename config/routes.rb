PrivatePractice::Application.routes.draw do
  scope "(:locale)", :locale => /en|nl/ do
    resources :images

    resources :password_resets, :except => :destroy

    resources :email_confirmations, :except => [:index,:destroy]

    resources :user_sessions, :only => [:new,:create,:destroy]

    resources :bookings, :except => [:edit,:update] do
      collection do
        put :index
      end
    end

    resources :messages, :except => [:edit, :update, :index] do
      collection do
        post :update_contact
      end
    end

    resources :appointments do
      member do
        get :unbook
        post :move
      end
    end

    resources :users do
      member do
        get :admin
        post :update_admin
        get :contact_info
        get :edit_contact_info
        get :messages
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
  end
  
  match '/:locale/signup' => 'users#new', :as => 'signup'
  match '/:locale/signin' => 'user_sessions#new', :as => 'signin'
  match '/:locale/signout' => 'user_sessions#destroy', :as => 'signout'
  match '/:locale/contact' => 'users#contact', :as => 'contact'
  match '/:locale/route' => 'pages#route', :as => 'route'
  
  match '(/:locale)' => "pages#homepage"
  root :to => "pages#homepage"
end
