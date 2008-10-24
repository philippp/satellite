ActionController::Routing::Routes.draw do |map|
  map.resources :albums

  map.resources :photos
  map.resource :password_reset
  map.resource :session
  map.resources :users do |user|
    # UserAssetsController knows how to deal with the 
    # polymorphic relationship between an Asset and its
    # 'attachable'.  
    # We use the resource_fu :opaque_name option so that the
    # url looks clean independent of url helper and route names.
    user.resources :user_assets, :opaque_name => :assets do |asset|
      asset.resources :tags
    end
  end

  map.connect ':controller/service.wsdl', :action => 'wsdl'
  map.connect '', :controller => 'users', :conditions => { :subdomain => '', :domain => ROUTE_DOMAIN }
  map.connect '', :controller => 'users', :action => 'show'

  map.home '', :controller => 'users', :domain => ROUTE_DOMAIN, :subdomain => false

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
