require 'spec_helper'

describe "Counting" do
  before(:each) do
    @organization = FactoryGirl.create(:organization)
    @user = FactoryGirl.create(:user, :organization => @organization)
    @project = FactoryGirl.create(:project, :organization => @organization)
    @project_member = FactoryGirl.create(:project_member, :project => @project, :user => @user)
    # TODO: create Segment's and GeoPoint's and GeoPointOnSegment's
    # TODO: create CountPlan
  end

  it "lasts for the scheduled number of seconds" do
    pending "the writing of this test"
  end

  it "records the proper number of counts" do
    pending "the writing of this test"

    # TODO: include presses of all three buttons: +1, +5, -1
    # (1..10).each do
    #   click_link '+1'
    # end
    # click_link '-1'
    # click_link '+5'
    # # expected count is 14
  end
end