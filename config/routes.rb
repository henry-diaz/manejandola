Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }

  resources :trainings, only: [:index, :show]
  get '/trainings/answers/:id/:answer_id', to: 'trainings#answers', as: 'answer_training'
  resources :learn, only: [:index]
  get '/learn/:category', to: 'learn#index', as: 'category_learn'
  resources :practices, only: [:index, :show]
  get '/practices/answers/:id/:answer_id', to: 'practices#answers', as: 'answer_practice'
  get '/practices/respond/:id/:answer_id', to: 'practices#respond', as: 'respond_practice'

  root 'home#index'

end
