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
  
  it "should require a name"
end