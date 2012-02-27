Pedplus::Application.routes.draw do
  root :to => 'app#dashboard'
  match 'app' => 'app#app'
  match 'smartphone' => 'smartphone#dashboard'
  # TODO: add route for /help
  namespace :manage do
    root :to => 'site#dashboard'
    resources :users, :projects
    resources :organizations, :only => [:show, :edit, :update]
  end

  namespace :api do
    resources :organizations
    resources :users
    resources :projects do
      resources :geo_points,
                :segments,
                :geo_point_on_segments,
                :scenarios,
                :segment_in_scenarios,
                :model_jobs
      resources :count_sessions do
        resources :counts
      end
    end
    resources :data_sources
    match 'map_edits' => 'map_edits#upload'
  end
  
  devise_for :users
  
  # admin is only for S3Sol internal users
  namespace :admin do
    root :to => 'site#dashboard'
    resources :users, :organizations, :projects, :oauth_clients
  end

  # probably letting all users access, not just admin ones
  authenticate :user do
    mount Resque::Server, :at => "/admin/resque"
  end
end
