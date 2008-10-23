require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/photos/new.html.erb" do
  include PhotosHelper
  
  before(:each) do
    @current_user = stub_model(User)
    controller.stub!(:current_user).and_return(@current_user)
    assigns[:photo] = stub_model(Photo,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/photos/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", photos_path(:format => :iframe)) do
    end
  end
end


