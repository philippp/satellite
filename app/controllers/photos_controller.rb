class PhotosController < UserAssetsController

  delegate_resources_helpers :assets, :to => :photos, :controller => :photos
  delegate_url_helpers :asset_attachable, :to => :user

  def create
    @asset = assets.build(params[:asset])

    responds_to_parent do |format|
      if @asset.save
        flash[:notice] = 'Asset was successfully created.'
        format.html { render :template => "photos/create.js.rjs" }
        format.xml  { head :created, :location => asset_url(@asset) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @asset.errors.to_xml }
      end
    end
  end

protected
  def load_attachable
    # We do both @user and @attachable because @attachable is used by the assets_controller
    # and @user is used when inferring missing path segments in the url helpers
    @attachable = @user
  end

end
