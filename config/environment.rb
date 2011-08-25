# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Urbped::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => "s3sol.com",
  :password => "senditn0w",
  :domain => "s3sol.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}