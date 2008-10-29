# A +Friend+ represents an individual who is relevant to the +User+. Points of contact are stored as +Contact+ instances and associated with the +Friend+. A +Friend+ may also be associated with an +Assets+ by the creation of a +Tag+.
class Friend < ActiveRecord::Base

  validates_presence_of :name
  has_many :tags, :dependent => :destroy
  has_many :contacts, :dependent => :destroy do
    # All email addresses associated with this friend
    def find_emails
      find_contact_details("email")
    end
    
    # All Facebook IDs associated with this +Friend+
    def find_facebook
      # All Facebook IDs associated with this friend
      find_contact_details("facebook") 
    end

    # Find +Contact+ of this +Friend+ by specified +email+ 
    def find_by_email(email)
      find_of_type_with_detail("email", email)
    end

    # Find +Contacts+ of this +Friend+ by type (ex: email) and detail/point (ex: phil@deluux.com)
    def find_of_type_with_detail(type, detail)
      find(:first, :conditions => ["contacts.contact_type = ? AND contacts.point = ?", type, detail])
    end
    
    # Find all +Contacts+ of specified +type+ belonging to this +Friend+ 
    def find_contact_type(type)
      find(:all, :conditions => ["contact_type = ?", type])
    end
  end

  
  # Initializes a Contact and Friend instance if none exists.
  # This function strips the formatted name of non-alphanumeric symbols after 
  # attempting to extract an email address.
  # name::   Best-guess name of this friend
  # email::   Optional known email. 
  # source:: Optional source id
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
  
  # Creates a Contact and Friend instance if none exists. Wraps +lookup_or_initialize_by_name+.
  # name:: Best-guess name of this friend
  # email:: Optional known email. 
  # source:: Optional source id  
  def self.lookup_or_create_by_name(name, email=nil, source=nil)
    friend = lookup_or_initialize_by_name(name, email, source)
    friend.save
    friend
  end
  
  # Descriptive ID
  def to_param
    return "#{self.id}-#{self.name.gsub(/\W/,'-')}" if self.name
    return self.id.to_s
  end



end
