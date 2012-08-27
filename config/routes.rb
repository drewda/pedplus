Pedplus::Application.routes.draw do
  root :to => 'app#dashboard'
  match 'app' => 'app#app'
  match 'smartphone' => 'smartphone#dashboard'

  namespace :manage do
    root :to => 'site#dashboard'
    resources :users, :projects
    resources :organizations, :only => [:show, :edit, :update]
  end

  namespace :api do
    resources :tokens, :only => [:create, :destroy]
    resources :organizations
    resources :users
    resources :projects do
      resources :geo_points,
                :segments,
                :geo_point_on_segments,
                :scenarios,
                :segment_in_scenarios,
                :model_jobs
      resources :count_plans do
        resources :gate_groups
        resources :gates
      end
      resources :count_sessions do
        resources :counts
      end
    end
    match 'map_edits' => 'map_edits#upload'
  end
  
  devise_for :users
  
  # admin is only for S3Sol internal users
  namespace :admin do
    root :to => 'site#dashboard'
    resources :organizations do
      resources :users, :projects
    end
  end

  # probably letting all users access, not just admin ones
  authenticate :user do
    mount Resque::Server, :at => "/admin/resque"
  end
end
