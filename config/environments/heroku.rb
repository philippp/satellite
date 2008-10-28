# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true


# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

RAILS_GEM_VERSION = '2.1'

ROUTE_DOMAIN = "heroku.com"
DOMAIN = "#{ROUTE_DOMAIN}"

PAGE_SIZE = 16

API_KEYS['SMUGMUG_API_KEY']  = ""
API_KEYS['FLICKR_API_SECRET'] = ""
API_KEYS['FLICKR_API_SHARED'] = ""
