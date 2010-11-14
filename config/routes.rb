PrivatePractice::Application.routes.draw do
  resources :pages
  resources :images

  match 'pages/:id/toggle' => 'pages#toggle', :as => :toggle
  match 'pages/:id/up' => 'pages#up', :as => :up
  match 'pages/:id/down' => 'pages#down', :as => :down
  match 'pages/changelocale' => 'pages#changelocale', :as => :changelocale

  root :to => "pages#homepage"
end
