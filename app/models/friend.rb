class Friend < ActiveRecord::Base

  validates_presence_of :name
  has_many :tags, :dependent => :destroy
  has_many :contacts, :dependent => :destroy do
    def find_emails
      find_contact_details("email")
    end

    def find_facebook
      find_contact_details("facebook")
    end

    def find_by_email(email)
      find_of_type_with_detail("email", email)
    end

    def find_of_type_with_detail(type, detail)
      find(:first, :conditions => ["contacts.contact_type = ? AND contacts.point = ?", type, detail])
    end

    def find_contact_type(type)
      find(:all, :conditions => ["contact_type = ?", type])
    end
  end

  
  # Create a Contact and Friend if Friend is not found. 
  # Formats submitted name.
  def self.lookup_or_initialize_by_name(name, email=nil, source=nil)    
    if name.include? '('
      name = name.split("(")[0].strip
    elsif name.include? "@" and name.include? "."
      email ||= name
      # "paul.jones@paul.com" => "paul.jones"
      name = name.split("@").first
      # "paul.jones" => "Paul Jones"
      name = name.split(/\W/).collect{|x| x.capitalize }.join(" ")
    end
    
    # Attempt to find friend by name
    friend = self.find_by_name(name)
    return friend if friend
    
    # Attempt to find friend by email
    contact = Contact.find(:first, :conditions => {:point => email, :contact_type => "email" })
    return contact.friend if contact
    
    # Create new friend and contact
    friend = self.new(:name => name)
    if email
      contact = Contact.new(:point => email,
                            :contact_type => "email",
                            :source => source || "lookup_or_initialize_by_name")
      friend.contacts << contact
    end
    friend
  end
  
  def self.lookup_or_create_by_name(name, email=nil, source=nil)
    friend = lookup_or_initialize_by_name(name, email, source)
    friend.save
    friend
  end
  
  def to_param
    return "#{self.id}-#{self.name.gsub(/\W/,'-')}" if self.name
    return self.id.to_s
  end



end
