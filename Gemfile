source 'http://rubygems.org'

gem 'rails', '3.2.3'

gem 'mysql2'

gem 'airbrake'
gem 'capistrano'

gem 'resque', :require => "resque/server"
# gem 'juggernaut', :git => 'https://github.com/maccman/juggernaut.git'

gem 'devise'
gem 'devise_invitable'

gem "geocoder"

gem 'slim'
gem 'simple_form'
gem 'dynamic_form'
gem 'attribute_choices'
gem 'country_select'
gem 'validate_url'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'ejs'

gem 'jquery-rails'

group :assets do
  gem 'sass-rails'
  gem "less"
  gem 'coffee-rails'
  gem 'uglifier'
end

group :development do
  gem 'drewda-railroad', '~> 0.5.3'
  gem 'pry'
end

gem 'rspec-rails', :group => [:development, :test]

group :test, :darwin do
	gem 'factory_girl_rails'
	gem 'spork'
	gem 'database_cleaner'
	gem 'capybara'
	gem 'capybara-webkit'
	gem 'launchy' # used for save_and_open_page()
	gem 'timecop' # added for testing the times associated with CountSession's
	gem 'guard-rspec'
	gem 'guard-spork'
	gem 'guard-livereload'
	# for use while developing on Mac OS X
	gem 'rb-fsevent', :require => false
	gem 'growl', :require => false
end