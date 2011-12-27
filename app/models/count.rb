class Count < ActiveRecord::Base
  belongs_to :count_session, :counter_cache => true
end
