Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }

  resources :trainings, only: [:index, :show]
  get '/trainings/answers/:id/:answer_id', to: 'trainings#answers', as: 'answer_training'
  resources :learn, only: [:index]
  get '/learn/:category', to: 'learn#index', as: 'category_learn'

  root 'home#index'

end
