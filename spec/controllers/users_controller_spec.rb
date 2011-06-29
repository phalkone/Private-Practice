require 'spec_helper'

describe UsersController do
  render_views
  
    describe "GET 'new'" do
      
      it "should be successful" do
        get 'new'
        response.should be_success
      end
    end
    
    describe "GET 'show'" do
      
      before(:each) do
        Role.create(:title => "patient")
        @user = Factory(:user)
        controller.sign_in(@user)
      end
    
      it "should be successful" do
        get :show, :id => @user
        response.should be_success
      end
      
      it "should find the right user" do
        get :show, :id => @user
        assigns(:user).should == @user
      end
    end
    
     describe "POST 'create'" do

        describe "failure" do

          before(:each) do
            @attr = { :name => "", :email => "", :password => "",
              :password_confirmation => "" }
          end

          it "should not create a user" do 
            lambda do
              post :create, :user => @attr, :commit => controller.t("users.submit.new")
            end.should_not change(User, :count)
          end

          it "should render the 'new' page" do
            post :create, :user => @attr, :commit => controller.t("users.submit.new")
            response.should render_template('new')
          end
        end
        
        describe "success" do
          
          before(:each) do
            Role.create(:title => "patient")
            @attr = { :first_name => "New", :last_name => "User",
              :email => "user@example.com", :password => "foobar", 
              :password_confirmation => "foobar" }
          end
            
          it "should create a user" do
            lambda do
              post :create, :user => @attr, :commit => controller.t("users.submit.new")
            end.should change(User, :count).by(1)
          end
            
          it "should redirect to the user show page" do 
            post :create, :user => @attr, :commit => controller.t("users.submit.new")
            response.should redirect_to(user_path(assigns(:user)))
          end
          
          it "should have a welcome message" do
            post :create, :user => @attr, :commit => controller.t("users.submit.new")
            flash[:success].should == controller.t("users.created")
          end
        end
      end
end