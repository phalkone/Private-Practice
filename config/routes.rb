PrivatePractice::Application.routes.draw do
  resources :images

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

  root :to => "pages#homepage"
end
