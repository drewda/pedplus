Pedplus::Application.routes.draw do
  root :to => 'app#dashboard'
  
  namespace :api do
    resources :projects,
              :data_sources, 
              :geo_points,
              :segments,
              :geo_point_on_segments,
              :count_sessions,
              :counts,
              :scenarios,
              :segment_in_scenarios
  end
  
  devise_for :users
  
  namespace :admin do
    root :to => 'site#dashboard'
    resources :users, :organizations, :projects, :subscriptions, :oauth_clients
  end
end
