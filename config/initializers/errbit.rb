Airbrake.configure do |config|
  config.api_key    = '081f3d70d10a9fbb3e4292319ae49287'
  config.host       = 'errbit.s3sol.com'
  config.port       = 80
  config.secure     = config.port == 443
end