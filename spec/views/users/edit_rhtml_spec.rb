require File.dirname(__FILE__) + '/../../spec_helper'

context "/users/edit.rhtml" do
  include UsersHelper
  
  before(:each) do
    @errors = mock("errors")
    @errors.stub!(:count).and_return(0)

    @user = mock_model(User, :errors => @errors, 
      :login => 'Foo', 
      :email => 'foo@test.bar', 
      :password => nil, :password_confirmation => nil,
      :time_zone => 'Etc/UTC')

    assigns[:user] = @user
    @user.stub!(:domain)
    @user.stub!(:url).and_return("http://foo.#{DOMAIN}/")
    @user.stub!("domain?").and_return(false)
  end

  specify "should render edit form" do
    render "/users/edit.rhtml"
    response.should have_tag('form', :attributes =>{:action => user_path(@user), :method => 'post'})

  end
end


