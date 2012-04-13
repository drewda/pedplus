require 'spec_helper'

describe "Count planning" do
  before(:each) do
    @organization = FactoryGirl.create(:organization)
    @user = FactoryGirl.create(:user, :organization => @organization)
    @project = FactoryGirl.create(:project, :organization => @organization)
    @project_member = FactoryGirl.create(:project_member, :project => @project, :user => @user)
  end

  it 'guides user to create a new count plan when one does not already exist', :js => true do
      # sign in to the desktop + tablet app
      visit "/app"
      fill_in 'user_email', :with => @user.email
      fill_in "user_password", :with => @user.password
      click_button "Sign in"

      # select the appropriate project
      find('#projects-modal').click_link @project.name

      # switch to the Measure tab
      find('#top-bar').click_link "Measure"

      # switch to the Measure>Plan subtab
      find('#measure-sub-tabs').click_link "Plan"

      find('#measure-tab-plan.edit').should have_content 'Save Count Plan'
      # should have the "Save Count Plan" button
  end
end