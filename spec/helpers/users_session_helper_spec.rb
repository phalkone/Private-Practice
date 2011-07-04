require 'spec_helper'

describe UserSessionsHelper do
  
  describe "signed_in?" do
    before(:each) do
      activate_authlogic
      Role.create(:title => "patient")
      @user = Factory(:user)
    end
    
    it "should return true if signed in" do
      helper.signed_in?.should be_true
    end
    
    it "should return false if not signed in" do
      UserSession.find.destroy
      helper.signed_in?.should be_false
    end
  end
  
  describe "current_user" do
    before(:each) do
      activate_authlogic
      Role.create(:title => "patient")
      @user = Factory(:user)
    end
    
    it "should return the current user if logged in" do
      helper.current_user.should == @user
    end
    
    it "should return nil if not logged in" do
      UserSession.find.destroy
      helper.current_user.should == nil
    end
  end
  
  describe "role?" do
    before(:each) do
      activate_authlogic
      Role.create(:title => "patient")
      @user = Factory(:user)
    end
    
    it "should be true if the user has a certain role" do
      new_role = Role.create(:title => "new_role")
      @user.roles << new_role
      helper.role?("new_role").should be_true
    end
    
    it "should be false does not have a certain role" do
      helper.role?("new_role").should be_false
    end
    
    it "should be false if no user is logged in" do
      UserSession.find.destroy
      helper.role?("patient").should be_false
    end
  end
  
end