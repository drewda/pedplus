Pedplus::Application.routes.draw do
  root :to => 'site#dashboard'
  
  namespace :api do
    resources :ped_projects,
              :data_sources, 
              :geo_points,
              :segments,
              :geo_point_on_segments,
              :count_sessions,
              :counts,
              :scenarios,
              :segment_in_scenarios
  end
end
