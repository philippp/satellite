# Demo command line tasks exercising / testing the smugmug transport
namespace :smugmug_transport_test do
  
  ###
  # Authentication Example
  ###
  
  desc "Authenticate Smugmug and get a token"
  task( :auth => :environment ) do
    unless ENV.include? ("email") and ENV.include?("password")
      raise "usage: rake smugmug_transport_test:auth email='...' password='...'"
    end
    
    require 'smugmug_transport'
    require 'net_http_retrypatch'
    
    sm = SmugmugTransport.new
    pp sm.login_raw(ENV['email'], ENV['password'])
  end
  
  
  ###
  # Import Example
  ###
  
  desc "Import photos from Smugmug (requires token)"
  task( :import => :environment ) do
    
    unless ENV.include? ("user_id") and ENV.include?("pw_hash")
      raise "usage: rake myspace_transport:import user_id='...' pw_hash='...'\n"+
        "Call smugmug_transport_test:auth to get the hash.\n"+
        "!! USE SINGLE QUOTES AROUND THE HASH PARAMETER !!"
    end
    
    require 'smugmug_transport'
    require 'net_http_retrypatch'
    
    sm = SmugmugTransport.new    
    sm.login_hash(ENV["user_id"], ENV["pw_hash"])
    
    sm.api_call("smugmug.albums.get").each do |response_idx, album_desc|
      next unless response_idx =~ /^[-+]?[0-9]*$/
      puts "Getting Album #{album_desc['Title']}"
      image_arrs = sm.api_call("smugmug.images.get", { "AlbumID" => album_desc["AlbumID"] })
      image_arrs.each do |response_idx, img_id| 
        next unless response_idx =~ /^[-+]?[0-9]*$/ 
        image_info = sm.api_call("smugmug.images.getInfo", { "ImageID" => img_id})
        pp image_info
      end
    end # sm.api_call("smugmug.albums.get").each
  end
  


end
