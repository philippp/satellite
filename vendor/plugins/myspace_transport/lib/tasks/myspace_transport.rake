# Demo command line tasks exercising / testing the myspace transport
namespace :myspace_transport do
  
  desc "Import photos from myspace"
  task( :import => :environment ) do
    
    unless ENV.include? ("email") and ENV.include?("password")
      raise "usage: rake myspace_transport_test:import email=... password=..."
    end
    
    require 'myspace_mech'
    require 'net_http_retrypatch'
    
    mm = MyspacePictureDownloader.new
    unless mm.login(ENV["email"], ENV["password"])
      raise "Could not log in with #{ENV['email']} / #{ENV['password']}"
    end
    # The easy way: mm.get_all_images
    # Illustrative:

    titles = mm.album_titles
    puts "Found #{titles.size} albums: #{titles.join(' ')}"
    images = { }
    titles.each { |title|
      puts "Retrieving photos for #{title}"
      images[title] = mm.get_album_images(title)
      pp images[title]
    }
    #pp images
  end

  desc "Export a photo to myspace"
  task( :export => :environment ) do
    
    require 'myspace_mech'
    require 'net_http_retrypatch'
    
    unless ENV.include? ("email") and ENV.include?("password") and ENV.include?("img_path")
      raise "usage: rake myspace_transport_test:export email=... password=... img_path=... [album_name=...]"
    end
    
    mm = MyspacePictureUploader.new
    mm.login(ENV["email"], ENV["password"])
    
    report = mm.upload(ENV["img_path"], ENV["album_name"])
    pp report
  end


end
