namespace :contacts do

  desc "This task will import your gmail contacts"
  task( :import => :environment ) do
   
    BAD_DOMAINS = %w{ craigslist.org googlegroups.com }
    
    unless ENV.include? ("service") and ENV.include?("email") and ENV.include?("password")
      raise "usage: rake contacts:import_gmail email=(gmail adress) password=(gmail password)"
    end
    
    require 'contacts'
    friends = []
    puts "Attempting #{ENV['service']} import"
    contacts = Contacts.new(ENV["service"], ENV["email"], ENV["password"]).contacts
    puts "Downloaded #{contacts.length} #{ENV['service']} contacts"
    
    contacts.each{ |contact|
      if BAD_DOMAINS.include?(contact[1].split("@").last)
        puts "Rejecting #{contact[1]}"
        next
      end
      friends << Friend.lookup_or_create_by_name(contact[0]||contact[1], contact[1], ENV['service'])
    }
    puts "Imported #{friends.size} friends after domain filtering"
  end


end
