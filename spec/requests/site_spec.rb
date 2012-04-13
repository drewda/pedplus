require 'spec_helper'

describe "Site" do
  before(:each) do
    # create the organization and user
    @organization = FactoryGirl.create(:organization)
    @user = FactoryGirl.create(:user, :organization => @organization)
  end

  describe "authentication" do
    it "allows user to sign in", :js => true do
      # visit the root page and enter e-mail and password
      visit "/"
      fill_in 'user_email', :with => @user.email
      fill_in "user_password", :with => @user.password
      click_button "Sign in"

      page.should have_content "Welcome #{@user.full_name()}"
      # that's what we would expect to see on a successful sign-in
    end
  end

  describe "authorization" do
    it "lists projects for the appropriate users", :js => true do
      # also create the project and project_member
      @project = FactoryGirl.create(:project, :organization => @organization)
      @project_member = FactoryGirl.create(:project_member, :project => @project, :user => @user)

      # sign in to the desktop + tablet app
      visit "/app"
      fill_in 'user_email', :with => @user.email
      fill_in "user_password", :with => @user.password
      click_button "Sign in"

      find('#projects-modal').should have_content @project.name
      # the projects modal, when it appears, should list the appropriate project
    end

    it "does not list projects that the user is not authorized to see", :js => true do
      # create two projects, but add project membership for only one
      @project1 = FactoryGirl.create(:project, :organization => @organization)
      @project2 = FactoryGirl.create(:project, :organization => @organization)
      @project_member = FactoryGirl.create(:project_member, :project => @project1, :user => @user)

      # sign in to the desktop + tablet app
      visit "/app"
      fill_in 'user_email', :with => @user.email
      fill_in "user_password", :with => @user.password
      click_button "Sign in"

      find('#projects-modal').should_not have_content @project2.name
      # the projects modal, when it appears, should NOT list the second project's name

      # TODO: handle the case of users with access to zero projects
    end
  end
end