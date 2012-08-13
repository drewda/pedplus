# == Schema Information
#
# Table name: counts
#
#  id               :integer          not null, primary key
#  count_session_id :integer
#  at               :datetime
#  created_at       :datetime
#  updated_at       :datetime
#
# Indexes
#
#  index_counts_on_count_session_id  (count_session_id)
#

class Count < ActiveRecord::Base
  belongs_to :count_session, :counter_cache => true
end
