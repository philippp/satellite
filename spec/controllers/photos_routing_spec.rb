require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhotosController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "photos", :action => "index").should == "/photos"
    end
  
    it "should map #new" do
      route_for(:controller => "photos", :action => "new").should == "/photos/new"
    end
  
    it "should map #show" do
      route_for(:controller => "photos", :action => "show", :id => 1).should == "/photos/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "photos", :action => "edit", :id => 1).should == "/photos/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "photos", :action => "update", :id => 1).should == "/photos/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "photos", :action => "destroy", :id => 1).should == "/photos/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/photos").should == {:controller => "photos", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/photos/new").should == {:controller => "photos", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/photos").should == {:controller => "photos", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/photos/1").should == {:controller => "photos", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/photos/1/edit").should == {:controller => "photos", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/photos/1").should == {:controller => "photos", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/photos/1").should == {:controller => "photos", :action => "destroy", :id => "1"}
    end
  end
end
