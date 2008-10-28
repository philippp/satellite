namespace :heroku do
  
  @heroku_client = nil
  @name = ""
  @git = nil
  

  desc "Create a new Deluux instance on Heroku"
  task( :deploy => :environment ) do
    pre_configure
    @name = ENV["name"]
    @heroku_client = Heroku::Client.new(ENV["hk_email"], ENV["hk_password"])
    
    find_or_create_heroku_instance
    
    puts "Attempting to deploy with git via a system call"
    Kernel.system("cd #{RAILS_ROOT}; git push -v -f git@heroku.com:#{@name}.git")    
    
    temp_pass = random_string(8)
    
    @heroku_client.rake @name, "heroku:initialize_environment"
    @heroku_client.rake @name, "db:migrate"
    @heroku_client.rake @name, "heroku:initialize_user name=#{@name} email=#{ENV["hk_email"]} pass=#{temp_pass}"
    @heroku_client.update( @name, { :mode => 'production', :public => 'true'} ) 
    puts ".--------------------------------------------------------------------------\n"+
         "|All done!\n"
         "|Log in as #{@name} with password #{temp_pass} at http://#{@name}.heroku.com\n"+
         "'-------------------------------------------------------------------------"

  end
  
  
  desc "Copy Heroku environment files over deploy.rb and production.rb on the instance"
  task( :initialize_environment ) do
    require 'ftools'
    File.copy("#{RAILS_ROOT}/config/environments/heroku.rb", "#{RAILS_ROOT}/config/environments/development.rb") 
    File.copy("#{RAILS_ROOT}/config/environments/heroku.rb", "#{RAILS_ROOT}/config/environments/production.rb")   
  end
  
  desc "Initialize the first User on the Heroku instance"
  task( :initialize_user => :environment ) do
    
    unless ENV["name"] and ENV["pass"] and env["email"]
      die("Usage: rake heroku:initialize_user name=... pass=... email=...\n"+
          "name : Name of the Heroku instance and first user\n"+
          "pass : Temporary password\n"+
          "email: Email contact")
    end

    if User.find(:first).nil?
      u = User.create(:name => ENV["name"], :password => ENV["pass"])
    end
  end
  
  

  # 1. Create Heroku instance. If this succeeds, we assume the instance is created.
  def find_or_create_heroku_instance
    begin 
     info = @heroku_client.info @name 
     puts "Found existing instance '#{@name}':"; pp info
    rescue RestClient::ResourceNotFound
      begin
        @heroku_client.create @name
        info = @heroku_client.info @name 
        puts "Created new instance '#{@name}':"; pp info
      rescue Exception => e
      die "Failed to find or create Heroku instance '#{ENV['name']}'\n#{e.inspect}\n"+
          "Try creating it in Heroku's web interface."
      end  
    end    
  end
  
  # 2. Deploy the current state of the repository to Heroku
  def deploy_with_git
  end
  
#### Helpers

  # Check dependendencies
  def pre_configure
    
    # Command-line params
    unless ENV.include? ("name") and ENV.include? ("hk_email") and ENV.include? ("hk_password")  
      die "Usage: rake heroku_config:initialize name=... hk_email=... hk_password=...\n"+
          "Where:\n"+
          "       name:         the new instance name\n"+
          "       hk_email:     your Heroku login email\n"+
          "       hk_password:  your Heroku password"
    end
    
    # Pre-requisites
    begin
      require 'rubygems' 
      require 'heroku' 
    rescue MissingSourceFile => e
      if e.inspect.include? "heroku"
        die "Please install the Heroku gem with 'gem install heroku'"
      end
    end
    
  end    
  
  # Get attention
  def die( msg )
    raise "---------------------------\n#{msg}\n-----------------------------"
  end
  
  def random_string( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  


end
