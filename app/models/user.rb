# == Schema Information
# Schema version: 20081004012912
#
# Table name: users
#
#  id                        :integer(4)    not null, primary key
#  login                     :string(255)
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  last_login_at             :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  visits_count              :integer(4)    default(0)
#  permalink                 :string(255)
#

require 'digest/sha1'
class User < ActiveRecord::Base
  include AuthenticatedBase
  has_many :assets, :as => :attachable
  has_one :password_reset

  validates_uniqueness_of :login, :email, :case_sensitive => false

  # Protect internal methods from mass-update.
  attr_accessible :login, :email, :password, :password_confirmation, :time_zone, :domain

  def to_param
    login
  end

  def self.find_by_param(*args)
    find_by_login *args
  end

  def self.find_by_subdomain(subdomain)
    options = {:conditions => ["users.login = ?", subdomain]}
    self.find(:first, options)
  end

  def domain_if_available
    if self.domain?
      self.domain
    else
      DOMAIN
    end
  end

  def subdomain
    self.login.downcase
  end

  def hostname_only
    if self.domain?
      self.domain
    elsif self.subdomain
      "#{self.subdomain}.#{ROUTE_DOMAIN}"
    end
  end

  # this is because url_for isn't monkey patched to do this
  # url_for(:host => .., :path => false)
  def url(request = nil, port = nil, params = {})
    url = "http://#{hostname_only}"
    if request and request.port != 80
      url += ":#{request.port}"
    elsif port and port != 80
      url += ":#{port}"
    end
    url += "/?#{params.to_query}" if params != {}
    url
  end

end
