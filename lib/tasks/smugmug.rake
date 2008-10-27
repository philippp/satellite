namespace :smugmug do
  
  #Smugmug Import Auth
  desc "Authenticate for Smugmug"
  task( :auth => :environment) do
    SMUGMUG_API_KEY = API_KEYS['SMUGMUG_API_KEY']
    unless ENV.include? ("email") and ENV.include?("password")
      raise "usage: rake smugmug:auth email=... password=..."
    end      
    smt = SmugmugTransport.new
    response = smt.login_raw ENV["email"], ENV["password"]
    SmugmugUser.find(:all).each{ |smu| smu.destroy } if response.include? :pw_hash
    SmugmugUser.create!(:user_id => response[:user_id], :pw_hash => response[:pw_hash])   
    puts "Authenticated. You can import with 'rake smugmug:import'."
  end

  
  #Smugmug Import
  desc "Import photos from Smugmug"
  task( :import => :environment ) do

    SMUGMUG_API_KEY = API_KEYS['SMUGMUG_API_KEY']
    if( (sm_user = SmugmugUser.find(:first)).nil? )
      raise "Authenticate with 'rake smugmug:auth email=... password=...' first."
    end
    
    album_importer = Importer.new(Album, "smugmug")
    asset_importer = Importer.new(Asset, "smugmug")
    
    sm = SmugmugTransport.new
    sm.login_hash sm_user.user_id, sm_user.pw_hash
    
    sm.api_call("smugmug.albums.get").each do |response_idx, album_desc|
      next unless response_idx =~ /^[-+]?[0-9]*$/ #only care about indexed albums

      puts "Getting Album #{album_desc['Title']}"      
      if album_importer.has_imported? album_desc['AlbumID']
        album = album_importer.find_imported album_desc['AlbumID']
      else
        album = album_importer.import( album_desc['AlbumID'], { :title => album_desc['Title'], :user_id => 1})
      end
    
      next if album.nil? # Don't update if it's gone
      
      image_arrs = sm.api_call("smugmug.images.get", { "AlbumID" => album_desc["AlbumID"] })
      image_arrs.each do |response_idx, img_id|
        next if asset_importer.has_imported? img_id or (response_idx =~ /^[-+]?[0-9]*$/).nil?

        image_info = sm.api_call("smugmug.images.getInfo", { "ImageID" => img_id})
        a = asset_importer.import(image_info["MD5Sum"], {
                                    :uploaded_url => image_info["OriginalURL"], 
                                    :title => image_info["Caption"], 
                                    :created_at => Time.parse(image_info["Date"]),
                                    :attachable_id => 1, 
                                    :attachable_type => "User" 
                                  } )
        album.assets << a
        puts "Imported #{image_info['Caption']} from #{image_info['OriginalURL']}"
      end
    end # sm.api_call("smugmug.albums.get").each

      
  end
  

end

