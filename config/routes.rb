PrivatePractice::Application.routes.draw do
  resources :patients
  resources :doctors
  resources :images

  resources :pages do
    member do
      get :toggle
      get :down
      get :up
      post :create
    end

    collection do
      post :changelocale
    end
  end

  root :to => "pages#homepage"
end
