Rails.application.routes.draw do
  use_doorkeeper

  get '/auth/:provider/callback', to: 'sessions#create'
  resource :session, only: %i[ new destroy ]
  get 'users/sign_out', to: 'sessions#destroy'

  get 'ping', to: 'heartbeat#ping', format: :json
  get 'healthcheck', to: 'heartbeat#healthcheck',  as: 'healthcheck', format: :json

  resources :apidocs, only: [:index]
  mount SwaggerEngine::Engine, at: "/api-docs"

  root to: 'home#show'

  resources :services
  resources :imports, only: [:new, :create] do
    get 'errors_log', on: :collection
  end

  namespace :api, format: :json do
    scope module: :v1, constraints: ApiConstraint.new(version: 1) do
      resources :offenders, format: :json, except: [:new, :create, :edit, :update, :destroy] do
        get :search, on: :collection
        patch :merge, on: :member
      end
      resources :identities, format: :json, except: [:new, :edit] do
        get :search, on: :collection
        get :inactive, on: :collection
        get :blank_nomis_offender_id, on: :collection
        patch :make_current, on: :member
        patch :activate, on: :member
      end
    end
  end
end
