Rails.application.routes.draw do
  resources :searches

  get '', to: 'searches#new', as: 'home'
  get 'suggestions', to: 'searches#show', as: 'suggestions'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
