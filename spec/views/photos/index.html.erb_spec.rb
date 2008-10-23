require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/photos/index.html.erb" do
  include PhotosHelper

  before(:each) do
    assigns[:page] = 0
    assigns[:user] = @user = stub_model(User)
    asset1 = stub_model(Photo)
    asset2 = stub_model(Photo)
    asset1.stub!(:public_filename).and_return("file")
    asset2.stub!(:public_filename).and_return("file")
    asset1.stub!(:updated_at).and_return(Time.now)
    asset2.stub!(:updated_at).and_return(Time.now)
    @controller.template.should_receive(:asset_path).with(asset1, :context => :all).exactly(1).times.and_return('PHOTOS_1_PATH')
    @controller.template.should_receive(:asset_path).with(asset2, :context => :all).exactly(1).times.and_return('PHOTOS_1_PATH')
    @assets = assigns[:assets] = [
      asset1,
      asset2
    ]
    @user.stub!(:assets).and_return(@assets)
  end

  it "should render list of photos" do
    render "/photos/index.html.erb"
  end
end

