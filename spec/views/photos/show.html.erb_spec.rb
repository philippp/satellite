require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/photos/show.html.erb" do
  include PhotosHelper
  
  before(:each) do
    assigns[:asset] = @asset = stub_model(Photo)
    @asset.stub!(:title).and_return("title")
    @asset.stub!(:public_filename).and_return("filename")
    @asset.stub!(:updated_at).and_return(Time.now)
    end

  it "should render attributes in <p>" do
    render "/photos/show.html.erb"
  end
end

