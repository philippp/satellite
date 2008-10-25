require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/albums/index.html.erb" do
  include AlbumsHelper
  
  before(:each) do
    assigns[:albums] = [
      stub_model(Album,
        :title => "value for title",
        :description => "value for description",
        :assets_count => "1"
      ),
      stub_model(Album,
        :title => "value for title",
        :description => "value for description",
        :assets_count => "1"
      )
    ]
  end

  it "should render list of albums" do
    render "/albums/index.html.erb"
    response.should have_tag("tr>td", "value for title", 2)
    response.should have_tag("tr>td", "value for description", 2)
    response.should have_tag("tr>td", "1", 2)
  end
end

