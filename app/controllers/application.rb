# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable
  include AccountLocation
  include PageMoth

  class AccessDenied < StandardError; end

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_trunk_session_id'

  before_filter :login_from_cookie
  before_filter :find_profile

  around_filter :catch_errors

  helper :all

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '2f17755d2b7b4e8e3dd03cef619dd505'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

  protected
    def self.protected_actions
      [ :edit, :update, :destroy ]
    end

    def request_has_domain?
      request.domain != ROUTE_DOMAIN
    end

    def request_has_subdomain?
      account_subdomain
    end

    def find_profile
      if request_has_domain?
        @user ||= User.find_by_domain(request.domain)
      elsif request_has_subdomain?
        @user ||= User.find_by_subdomain(account_subdomain)
      end

      if (request_has_domain? or request_has_subdomain?) and @user.nil?
        redirect_to home_url(:domain => ROUTE_DOMAIN, :subdomain => false), :status => 301
      end
    end

    # this is because url_for isn't monkey patched to do this
    # url_for(:host => .., :path => false)
    def user_url(user = @user, params = {})
      if user
        user.url(request, nil, params)
      end
    end

    # this is because url_for isn't monkey patched to do this
    # url_for(:host => .., :path => false)
    def user_path(user)
      user_url(user)
    end

    def login_user(user)
      self.current_user = user
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token,
                               :expires => self.current_user.remember_token_expires_at,
                               :domain => ".#{request.domain}" }
    end

  private

    def catch_errors
      begin
        yield

      rescue AccessDenied
        flash[:notice] = "You do not have access to that area."
        redirect_to '/'
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Sorry, can't find that record."
        redirect_to '/'
      end
    end

end
