class Api::ApiController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token # skip CSRF tokens for API

  # If you are using token authentication with APIs and using trackable. 
  # Every request will be considered as a new sign in (since there is no 
  # session in APIs). This is disabled by the following before filter:
  before_filter :skip_trackable
  def skip_trackable
    request.env['devise.skip_trackable'] = true
  end

  # a function used to pick out only certain param attributes to use to update records
  # http://www.quora.com/Backbone-js-1/How-well-does-backbone-js-work-with-rails
  def pick(hash, *keys)
    filtered = {}
    hash.each do |key, value| 
      filtered[key.to_sym] = value if keys.include?(key.to_sym) 
    end
    filtered
  end

  # http://stackoverflow.com/a/94626/40956
  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain" 
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      headers['Expires'] = "0" 
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end

    render :layout => false
  end
end