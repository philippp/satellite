require File.dirname(__FILE__) + '/../spec_helper'

context "Requesting with subdomain" do
  controller_name :users

  def do_get
    @request.host = "paul.test.host"
    get :show
  end

  specify "should be successful" do
    User.stub!(:find_by_subdomain).and_return(mock_user)
    do_get
    response.should be_success
  end

  specify "should be redirected" do
    do_get
    response.should be_redirect
  end

end

context "Requesting with domain" do
  controller_name :users

  def do_get
    @request.host = "paul.host"
    get :show
  end

  specify "should be unsuccessful" do
    User.stub!(:find_by_domain).and_return(nil)
    do_get
    response.should be_redirect
  end

  specify "should be successful" do
    User.stub!(:find_by_domain).and_return(mock_user)
    do_get
    response.should be_success
  end

end