class PhotosController < UserAssetsController

  delegate_resources_helpers :assets, :to => :photos, :controller => :photos
  delegate_url_helpers :asset_attachable, :to => :user

end
