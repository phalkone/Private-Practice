require 'spec_helper' 

describe Role do
  before(:each) do 
    @attr = { :title => "Patient" }
  end

  it "should create a new instance given valid attributes" do 
    Role.create!(@attr)
  end

end