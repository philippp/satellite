class Friend < ActiveRecord::Base

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

  
  # Create a contact and friend record if friend is not found. 
  # Formats submitted name.
  def self.lookup_or_initialize_by_name(name)    
    if name.include? '('
      name = name.split("(")[0].strip
    elsif name.include? "@" and name.include? "."
      email = name
      # "paul.jones@paul.com" => "paul.jones"
      name = name.split("@").first
      # "paul.jones" => "Paul Jones"
      name = name.split(/\W/).collect{|x| x.capitalize }.join(" ")
    end

    friend = self.find_by_name(name)
    return friend if friend

    friend = self.new(:name => name)

    if email
      contact = Contact.new(:point => email,
                            :contact_type => "email",
                            :source => "lookup_or_initialize_by_name")
      friend.contacts << contact
    end
    friend
  end
  
  def self.lookup_or_create_by_name(name)
    friend = lookup_or_initialize_by_name(name)
    friend.save
    friend
  end

end
