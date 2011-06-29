require 'spec_helper'

describe User do 
  before(:each) do 
    Role.create(:title => "admin")
    Role.create(:title => "doctor")
    Role.create(:title => "patient")
    @attr = { :last_name => "User", :first_name => "Example", 
      :email => "user@example.com", :password => "secret", 
      :password_confirmation => "secret" }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a first name" do
    no_name_user = User.new(@attr.merge(:first_name => ""))
    no_name_user.should_not be_valid
  end
  
  it "should require a last name" do
    no_name_user = User.new(@attr.merge(:last_name => ""))
    no_name_user.should_not be_valid
  end
  
  it "should require an email address if not doctor or administrator" do
    no_name_user = User.new(@attr.merge(:email => ""))
    no_name_user.should_not be_valid
  end
  
  it "should not require an email address if doctor or administrator" do
    no_name_user = User.new(@attr.merge(:email => "",:super_reg => 1))
    no_name_user.should be_valid
  end
  
  it "should reject first names that are too long" do
    long_name = "a" * 50
    long_name_user = User.new(@attr.merge(:first_name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should reject last names that are too long" do
    long_name = "a" * 50
    long_name_user = User.new(@attr.merge(:last_name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email adddresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each() do |address|
      new_user = User.new(@attr.merge(:email => address))
      new_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com  @foo.bar.org first.last]
    addresses.each() do |address|
      new_user = User.new(@attr.merge(:email => address))
      new_user.should_not be_valid
    end
  end
  
  it "should have a unique email" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr.merge(:email => @attr[:email].upcase))
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should require a password if not a doctor or administrator" do
    no_password_user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
    no_password_user.should_not be_valid
  end
  
  it "should not require a password if a doctor or administrator" do
    no_password_user = User.new(@attr.merge(:super_reg => 1, :password => "", 
      :password_confirmation => ""))
    no_password_user.should be_valid
  end
  
  it "should require a matching password validation" do
    no_match_user = User.new(@attr.merge(:password_confirmation => "no_secret"))
    no_match_user.should_not be_valid
  end
  
  it "should reject too short passwords" do
    too_short_user = User.new(@attr.merge(:password => "short", 
      :password_confirmation => "short"))
    too_short_user.should_not be_valid
  end
  
  it "should reject too long passwords" do
    long = "a"* 41
    too_short_user = User.new(@attr.merge(:password => long, 
      :password_confirmation => long))
    too_short_user.should_not be_valid
  end
  
  describe "authentication" do
    
    before(:each) do
      @user = User.create(@attr)
    end
    
    it "should be of default role patient" do
      @user.roles.should be_include(Role.find_by_title("patient"))
    end
  
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    it "should return true if password match" do
      @user.has_password?(@attr[:password]).should be_true
    end
    
    it "should return false if password do not match" do
      @user.has_password?("invalid").should be_false
    end
    
    it "should return user if authenticated succesfully" do
      User.authenticate(@attr[:email],@attr[:password]).should_not be_nil
    end
    
    it "should return be nil if authenticated unsuccesfully" do
      User.authenticate(@attr[:email],"invalid").should be_nil
    end
    
  end
  
end