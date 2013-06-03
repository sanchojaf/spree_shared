# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'spree/frontend'
require 'spree/api'
require File.expand_path("../dummy/config/environment",  __FILE__)

require 'rspec/rails'
require 'capybara/rspec'
require 'factory_girl'
require 'ffaker'
require 'database_cleaner'

require 'spree/testing_support/factories'
require 'spree/testing_support/factories/store_factory'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.after(:each) do
    Apartment::Database.reset
    DatabaseCleaner.clean
    connection = ActiveRecord::Base.connection.raw_connection
    schemas = connection.query(%Q{
      SELECT 'drop schema ' || nspname || ' cascade;'
      from pg_namespace 
      where nspname != 'public' 
      AND nspname NOT LIKE 'pg_%'
      AND nspname != 'information_schema';
    })
    schemas.each do |query|
      connection.query(query.values.first)
    end
  end
end
