require File.dirname(__FILE__) + '/../../spec_helper'

context "/users/index.rhtml" do
  include UsersHelper
  
  before(:each) do
    user_98 = mock_model(User, :id => 98, :login => 'joe')
    user_99 = mock_model(User, :id => 99, :login => 'mary')

    assigns[:users] = [user_98, user_99]
    user_98.stub!("domain?").and_return(false)
    user_99.stub!("domain?").and_return(false)
    user_98.stub!(:url).and_return("http://joe.#{DOMAIN}/")
    user_99.stub!(:url).and_return("http://mary.#{DOMAIN}/")
  end

  specify "should render list of users" do
    render "/users/index.rhtml"

  end
end

