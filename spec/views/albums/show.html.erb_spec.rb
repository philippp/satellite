require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/albums/show.html.erb" do
  include AlbumsHelper
  
  before(:each) do
    assigns[:album] = @album = stub_model(Album,
      :title => "value for title",
      :desciption => "value for desciption",
      :asset_count => "1"
    )
  end

  it "should render attributes in <p>" do
    render "/albums/show.html.erb"
    response.should have_text(/value\ for\ title/)
    response.should have_text(/value\ for\ desciption/)
    response.should have_text(/1/)
  end
end

