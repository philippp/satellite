# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'ruby-debug'
# include Spec
include Spec::Rails::Mocks
require File.dirname(__FILE__) + "/../lib/rspec_extensions.rb"


Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  def controller
    @controller
  end

  def mock_user
    user = mock_model(User,
      :id => 1,
      :login => 'flappy',
      :email => 'flappy@email.com',
      :password => '', :password_confirmation => ''
    )
  end

  def mock_asset
    user = mock_model(User,
      :public_filename => "filename",
      :width => 100,
      :height => 100,
      :width_guess => 100,
      :height_guess => 100,
      :cachebusted_filename => "cache_busted",
      :title_abr => "title",
      :comments_count => 0 )
  end

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end
