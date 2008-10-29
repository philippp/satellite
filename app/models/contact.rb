# A +Contact+ represents a single point of contact between the +User+ and a +Friend+. 
# +type+:: Specifies the communication channel of contact (ex: "email" or "facebook")
# +point+:: Unique identifier on the +type+ domain (ex: "phil@deluux.com" for +type+ "email") 
class Contact < ActiveRecord::Base

  belongs_to :friend
end
