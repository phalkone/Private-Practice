PrivatePractice::Application.routes.draw do
  resources :pages

  match 'pages/:id/toggle' => 'pages#toggle', :as => :toggle
  match 'pages/:id/up' => 'pages#up', :as => :up
  match 'pages/:id/down' => 'pages#down', :as => :down

  root :to => "pages#index"
end
