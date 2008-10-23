class PhotosController < UserAssetsController

  delegate_resources_helpers :assets, :to => :photos, :controller => :photos
  delegate_url_helpers :asset_attachable, :to => :user

protected
  def load_attachable
    # We do both @user and @attachable because @attachable is used by the assets_controller
    # and @user is used when inferring missing path segments in the url helpers
    @attachable = @user
  end

end
