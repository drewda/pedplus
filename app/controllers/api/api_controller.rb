class Api::ApiController < ApplicationController
  before_filter :authenticate_user!

  # a function used to pick out only certain param attributes to use to update records
  # http://www.quora.com/Backbone-js-1/How-well-does-backbone-js-work-with-rails
  def pick(hash, *keys)
    filtered = {}
    hash.each do |key, value| 
      filtered[key.to_sym] = value if keys.include?(key.to_sym) 
    end
    filtered
  end
end