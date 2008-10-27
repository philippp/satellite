namespace :contacts do

  desc "Import your gmail, yahoo, hotmail, and plaxo contacts"
  task( :import => :environment ) do

    unless ENV.include? ("service") and ENV.include?("email") and ENV.include?("password")
      raise "usage: rake contacts:import service=[gmail|yahoo|hotmail|plaxo] email=... password=..."
    end

    BAD_DOMAINS = %w{ craigslist.org googlegroups.com }
    
    require 'contacts'
    friends = []
    importer = Importer.new(Friend, ENV["service"], "lookup_or_create_by_name")

    puts "Attempting #{ENV['service']} import"
    
    contacts = Contacts.new(ENV["service"], ENV["email"], ENV["password"]).contacts
    
    puts "Downloaded #{contacts.length} #{ENV['service']} contacts"
    
    contacts.each{ |contact|
      if BAD_DOMAINS.include?(contact[1].split("@").last)
        puts "Rejecting #{contact[1]}"
        next
      end
      
      unless importer.has_imported?(contact[1])
        friends << importer.import(contact[1], contact[0]||contact[1], contact[1], ENV['service'])
      end

    }
    puts "Imported #{friends.size} friends after domain filtering"
  end


end
