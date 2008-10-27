namespace :myspace do

  # Myspace Import
  desc "Import photos from Myspace"
  task( :import => :environment ) do
    
    #required parameters
    unless ENV.include? ("email") and ENV.include?("password")
      raise "usage: rake myspace:import email=... password=..."
    end
    
    require 'myspace_mech'
    require 'net_http_retrypatch'
    
    album_importer = Importer.new(Album, "myspace")
    asset_importer = Importer.new(Asset, "myspace")
    
    mm = MyspacePictureDownloader.new
    
    unless mm.login(ENV["email"], ENV["password"])
      raise "Could not log in with #{ENV['email']} / #{ENV['password']}"
    end

    
    # Logged in to myspace, we can start importing

    titles = mm.album_titles
    puts "Found #{titles.size} albums: #{titles.join(' ')}"
    images = { }
    titles.each do |title|
      if album_importer.has_imported?(title)
        album = album_importer.find_imported(title)
      else
        album = album_importer.import(title, { :title => title, :user_id => 1 })  
      end
      next if album.nil?
      puts "Retrieving photos for #{title}"
      mm.get_album_images(title).each do |img_url|
        next if asset_importer.has_imported?(img_url)
        puts "Downloading #{img_url}"
        asset = asset_importer.import(img_url, :uploaded_url => img_url, :attachable_type => "User", :attachable_id => 1)
        album.assets << asset      
      end # mm.get_album_images(title).each
    end # titles.each { |title|
  end
  
end
