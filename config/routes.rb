Pedplus::Application.routes.draw do
  root :to => 'app#dashboard'
  
  namespace :api do
    resources :organizations
    resources :users
    resources :projects do
      resources :geo_points,
                :segments,
                :geo_point_on_segments,
                :scenarios,
                :segment_in_scenarios
      resources :count_sessions do
        resources :counts
      end
    end
    resources :data_sources
    match 'map_edits' => 'map_edits#upload'
  end
  
  devise_for :users
  
  namespace :admin do
    root :to => 'site#dashboard'
    resources :users, :organizations, :projects, :subscriptions, :oauth_clients
  end
end
