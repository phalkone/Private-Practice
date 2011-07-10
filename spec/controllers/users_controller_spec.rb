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
        activate_authlogic
        Role.create(:title => "patient")
        @user = Factory(:user)
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
            activate_authlogic
            @attr = { :first_name => "", :last_name => "",
              :email => "", :password => "",
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
            activate_authlogic
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
          
          it "should have a welcome message" do
            post :create, :user => @attr, :commit => controller.t("users.submit.new")
            flash[:success].should == controller.t("users.created")
          end
        end
    end

    describe "GET 'edit'" do
      before(:each) do
        activate_authlogic
        Role.create(:title => "patient")
        @user = Factory(:user)
        test_sign_in(@user)
      end
    
      it "should be successful" do
        get :edit, :id => @user
        response.should be_success
      end
        
      it "should have the right title" do
        get :edit, :id => @user 
        response.should have_selector("title", :content => controller.t("users.edittitle"))
      end
    end

    describe "PUT 'update'" do
      before(:each) do
        activate_authlogic
        Role.create(:title => "patient")
        @user = Factory(:user) 
        test_sign_in(@user)
      end 
      
      describe "failure" do
        before(:each) do
          @attr = { :email => "", :first_name => "", :last_name => "",
            :password => "", :password_confirmation => "" }
        end
        
        it "should render the 'edit' page" do
          put :update, :id => @user, :user => @attr, :commit => controller.t("users.submit.edit")
          response.should render_template('edit')
        end
        
        it "should have the right title" do
          put :update, :id => @user, :user => @attr, :commit => controller.t("users.submit.edit")
          response.should have_selector("title", :content => controller.t("users.edittitle"))
        end
      end
      
      describe "success" do
        before(:each) do
          activate_authlogic
          @attr = { :first_name => "New", :last_name => "Name", :email => "user@example.org",
            :password => "barbaz", :password_confirmation => "barbaz" }
        end
        
        it "should change the user's attributes" do
          put :update, :id => @user, :user => @attr, :commit => controller.t("users.submit.edit")
          @user.reload
          @user.first_name.should == @attr[:first_name] 
          @user.last_name.should == @attr[:last_name] 
          @user.email.should == @attr[:email]
        end
        
        it "should redirect to the user show page" do 
          put :update, :id => @user, :user => @attr, :commit => controller.t("users.submit.edit")
          response.should redirect_to(user_path(@user))
        end
        
        it "should have a flash message" do
          put :update, :id => @user, :user => @attr, :commit => controller.t("users.submit.edit")
          flash[:notice].should == controller.t("users.edited")
        end
      end
    end

    describe "authentication of edit/update/delete pages" do
      before(:each) do 
        activate_authlogic
        Role.create(:title => "patient")
        @user = Factory(:user)
        UserSession.find.destroy
      end
      
      describe "for non-signed-in users" do
        it "should deny access to 'edit'" do 
          get :edit, :id => @user
          response.should redirect_to(signin_path)
        end
        
        it "should deny access to 'destroy'" do 
          delete :destroy, :id => @user
          response.should redirect_to(signin_path)
        end
        
        it "should deny access to 'update'" do
          put :update, :id => @user, :user => {} 
          response.should redirect_to(signin_path)
        end
      end
    
      describe "for signed-in users" do
        before(:each) do
          activate_authlogic
          Role.create(:title => "patient")
          wrong_user = Factory(:user, :email => "user@example.net")
          test_sign_in(wrong_user)
        end
      
        it "should require matching users for 'edit'" do
          get :edit, :id => @user
          response.should redirect_to(root_path)
        end
        
        it "should require to be admin to 'destroy'" do
          delete :destroy, :id => @user
          response.should redirect_to(signin_path)
        end
        
        it "should require matching users for 'update'" do
          put :update, :id => @user, :user => {}
          response.should redirect_to(root_path)
        end
      end
    end
end