require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

ENV["RAILS_ENV"] ||= 'test'

Spork.prefork do
  require 'rails/application'

  # ward off problems with Devise
  # https://github.com/sporkrb/spork/wiki/Spork.trap_method-Jujitsu
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # no need for config.fixture_path because we're using FactoryGirl

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # use the webkit JS driver, rather than Selenium, for all Capybara request tests
    Capybara.javascript_driver = :webkit

    # config relevant to Spork
    # taken from http://railscasts.com/episodes/285-spork
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    # include Devise test helpers
    config.include Devise::TestHelpers, :type => :controller

    # database_cleaner (instead of transactional fixtures)
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
  FactoryGirl.reload
end
