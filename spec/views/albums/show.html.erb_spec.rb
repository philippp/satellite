require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/albums/show.html.erb" do
  include AlbumsHelper
  
  before(:each) do
    asset = mock_model(Asset, :public_filename => "filename", :width => 100, :height => 100,
                              :width_guess => 100, :height_guess => 100, :cachebusted_filename => "cache_busted",
                              :title_abr => "title", :comments_count => 0)
    assigns[:album] = @album = stub_model(Album,
      :id => 1,
      :title => "value for title",
      :description => "value for description",
      :assets_count => "1",
      :assets => [asset]
    )
    assigns[:page] = 0

    @controller.template.should_receive(:asset_path).with(asset, :context => "a_1").exactly(2).times.and_return('ASSET_PATH')
  end

  it "should render attributes in <p>" do
    render "/albums/show.html.erb"
    response.should have_text(/value\ for\ title/)
    response.should have_text(/value\ for\ description/)
    response.should have_text(/1/)
  end
end

