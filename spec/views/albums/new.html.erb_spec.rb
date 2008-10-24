require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/albums/new.html.erb" do
  include AlbumsHelper
  
  before(:each) do
    assigns[:album] = stub_model(Album,
      :new_record? => true,
      :title => "value for title",
      :description => "value for description",
      :asset_count => "1"
    )
  end

  it "should render new form" do
    render "/albums/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", albums_path) do
      with_tag("input#album_title[name=?]", "album[title]")
      with_tag("textarea#album_description[name=?]", "album[description]")
      with_tag("input#album_asset_count[name=?]", "album[asset_count]")
    end
  end
end


