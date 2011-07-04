require 'spec_helper'

describe UserSessionsController do 
  render_views
  
    describe "GET 'new'" do
      it "should be successful" do
        get :new 
        response.should be_success
      end
      
      it "should have the right title" do
        get :new
        response.should have_selector("title", 
          :content => controller.t("txt.signin"))
      end
    end
    
    describe "POST 'create'" do
      describe "invalid signin" do
        
        before(:each) do
          activate_authlogic
          @attr = { :email => "email@example.com", :password => "invalid" }
        end
        
        it "should re-render the new page" do
          post :create, :user_session => @attr
          response.should render_template('new')
        end
        
        it "should have the right title" do
          post :create, :user_session => @attr
          response.should have_selector("title", :content => controller.t("txt.signin"))
        end
        
        it "should have a flash.now message" do 
          post :create, :user_session => @attr
          response.should have_selector("div#error_explanation")
        end
      end
      
      describe "with valid email and password" do
        before(:each) do
          activate_authlogic
          Role.create(:title => "patient")
          @user = Factory(:user)
          UserSession.find.destroy
          @attr = { :email => @user.email, :password => @user.password, :remember_me => 0 }
        end
        
        it "should sign the user in" do
          post :create, :user_session => @attr
          controller.current_user.should == @user
          controller.should be_signed_in
        end
        
        it "should redirect to the user show page" do
          post :create, :user_session => @attr
          response.should redirect_to(user_path(@user))
        end
      end
    end
    
    describe "DELETE 'destroy'" do
      it "should sign a user out" do
        activate_authlogic
        Role.create(:title => "patient")
        test_sign_in(Factory(:user))
        delete :destroy, :id => {}
        controller.should_not be_signed_in 
        response.should redirect_to(root_path)
      end
  end
  
end