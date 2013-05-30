require 'simplecov'
SimpleCov.start 'rails'
require 'rubygems'
require 'spork'
require 'capybara/rspec'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require "rails/application"
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'accept_values_for'
  require 'discover'
  require 'database_cleaner'
  require 'capybara/rails'
  #require 'webrat'
  
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
  
  RSpec.configure do |config|
    config.mock_with :rspec
    config.infer_base_class_for_anonymous_controllers = false
    
    # For devise and controller specs
    config.include Devise::TestHelpers, :type => :controller
    config.extend ControllerMacros, :type => :controller
    config.include Devise::TestHelpers, :type => :helper
    config.extend ControllerMacros, :type => :helper
    config.extend ControllerMacros, :type => :request

    # DatabaseCleaner
    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
      #User.valid_roles.each{|r| FactoryGirl.create(:role, name: r.to_s)}
    end
  
    config.before(:each) do
      DatabaseCleaner.strategy = :transaction
    end
  
    config.before(:each, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end
  
    config.before(:each) do
      DatabaseCleaner.start
    end
  
    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
  end
end

Spork.each_run do
  FactoryGirl.reload
  DatabaseCleaner.clean
end
