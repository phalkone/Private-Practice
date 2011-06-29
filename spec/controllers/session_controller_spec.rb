require 'spec_helper'

describe SessionsController do 
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
          @attr = { :email => "email@example.com", :password => "invalid" }
        end
        
        it "should re-render the new page" do
          post :create, :session => @attr
          response.should render_template('new')
        end
        
        it "should have the right title" do
          post :create, :session => @attr
          response.should have_selector("title", :content => controller.t("txt.signin"))
        end
        
        it "should have a flash.now message" do 
          post :create, :session => @attr
          flash[:alert].should == controller.t("txt.invalid")
        end
      end
    end
end