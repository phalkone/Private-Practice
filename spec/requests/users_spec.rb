require 'spec_helper'

describe "Users" do
  describe "signup" do 
    it "should have the right title" do
      visit signup_path
      response.should have_selector('title', :content => controller.t("users.newtitle"))
    end
    
    describe "failure" do
      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in :user_first_name,            :with => ""
          fill_in :user_last_name,             :with => ""
          fill_in :user_email,                 :with => ""
          fill_in :user_password,              :with => ""
          fill_in :user_password_confirmation, :with => ""
          click_button :user_submit
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end 
    end
    
    describe "success" do
      it "should make a new user" do
        Role.create(:title => "patient")
        lambda do
          visit signup_path
          fill_in :user_first_name,            :with => "Example"
          fill_in :user_last_name,             :with => "User"
          fill_in :user_email,                 :with => "example@user.com"
          fill_in :user_password,              :with => "foobar"
          fill_in :user_password_confirmation, :with => "foobar"
          click_button :user_submit
        end.should change(User, :count).by(1)
      end 
    end
  end
end
