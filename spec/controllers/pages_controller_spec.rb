require 'spec_helper'

describe PagesController do
  render_views

  describe "GET 'homepage'" do
    it "should be successful" do
      get 'homepage'
      response.should be_success
    end
  end

end