require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/albums/edit.html.erb" do
  include AlbumsHelper
  
  before(:each) do
    assigns[:album] = @album = stub_model(Album,
      :new_record? => false,
      :title => "value for title",
      :desciption => "value for desciption",
      :asset_count => "1"
    )
  end

  it "should render edit form" do
    render "/albums/edit.html.erb"
    
    response.should have_tag("form[action=#{album_path(@album)}][method=post]") do
      with_tag('input#album_title[name=?]', "album[title]")
      with_tag('textarea#album_desciption[name=?]', "album[desciption]")
      with_tag('input#album_asset_count[name=?]', "album[asset_count]")
    end
  end
end


