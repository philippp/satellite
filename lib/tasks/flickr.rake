namespace :flickr do
  
  #Flickr Import Auth
  desc "Authenticate Flickr Integration"
  task( :auth => :environment) do
    require 'flickr'
    @flickr = Flickr.new(API_KEYS['FLICKR_API_SECRET'], API_KEYS['FLICKR_API_SHARED'])
    @flickr.auth.getFrob
    @auth_url = @flickr.auth.login_link('write')
    puts "Please authenticate at #{@auth_url}"
    while @flickr.auth.token.nil?
      sleep 5
      begin
        @flickr.auth.getToken
      rescue
      end
    end

    FlickrUser.find(:all).each{ |fu| fu.destroy! }
    fu = FlickrUser.create!(:session => Marshal.dump(@flickr))
  end

  
  #Flickr Import
  desc "Import Photos from Flickr"
  task( :import => :environment ) do
    require 'flickr'
    if( flickr_user = FlickrUser.find(:first)) 
      @flickr = Marshal.load(flickr_user.session)
    else      
      raise "Please authenticate with 'rake flickr:auth' first."
    end
        
    album_importer = Importer.new(Album, "flickr")
    asset_importer = Importer.new(Asset, "flickr")
    
    flickr_sets = @flickr.photosets.getList( @flickr.auth.token.user.nsid )
    flickr_sets.each{ |flickr_set|
      puts("Processing Flickr set \"#{flickr_set.title}\"")
      if album_importer.has_imported? flickr_set.id
        album = album_importer.find_imported flickr_set.id
      else
        album = album_importer.import( flickr_set.id, { 
                                         :title => flickr_set.title, 
                                         :description => flickr_set.description, 
                                         :user_id => 1 
                                       } )
      end
      next if album.nil? # Move on if it's deleted
      
      photos = flickr_set.fetch
      photos.each{ |photo|
        unless asset_importer.has_imported? photo.id
          pSizes = @flickr.photos.getSizes photo
          pInfo = @flickr.photos.getInfo photo
          
          asset = asset_importer.import(photo.id, 
                                        {
                                          :title => pInfo.title,  
                                          :description => pInfo.description, 
                                          :created_at => pInfo.dates[:taken] || pInfo.dates[:posted],
                                          :updated_at => pInfo.dates[:taken] || pInfo.dates[:posted],
                                          :uploaded_url => pSizes.sizes[:Original].source,
                                          :attachable_id => 1, 
                                          :attachable_type => "User"
                                        })
          album.assets << asset
        end
      }
    }
    photos = @flickr.photos.getNotInSet( nil, 500 )
    photos.each{ |photo|
        unless asset_importer.has_imported? photo.id
          pSizes = @flickr.photos.getSizes photo
          pInfo = @flickr.photos.getInfo photo

          asset = asset_importer.import(photo.id, 
                                        {
                                          :title => pInfo.title,  
                                          :description => pInfo.description, 
                                          :created_at => pInfo.dates[:taken] || pInfo.dates[:posted] || Time.now,
                                          :uploaded_url => pSizes.sizes[:Original].source,
                                          :attachable_id => 1, 
                                          :attachable_type => "User"
                                        })
        end      
    }      
  end
  

end

