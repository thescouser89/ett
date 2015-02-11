# Be sure to restart your server when you modify this file


# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'vestal_versions', :version => '0.8.3'
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_charset = "utf-8"
  config.action_mailer.smtp_settings = {
    :address => "smtp.corp.redhat.com",
    :port => 25,
    :domain => 'redhat.com',
    :authentication => :plain,
    :tls => true
  }

  # this tells rails to store all the data in the session into the database
  config.action_controller.session_store = :active_record_store

  config.gem "will_paginate", :source => "http://gemcutter.org", :version => '2.3.15'

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  require 'RedCloth'
  #require 'sparklines'

  APP_CONFIG = YAML::load(File.open("#{RAILS_ROOT}/config/appconfig.yml"))
end

ActionController::Base.cache_store = :file_store, "#{RAILS_ROOT}/cache"

require "xmlrpc/client"
require "open-uri"
require 'iniparse'
require 'xmlsimple'
require 'octokit'
XMLRPC::Config::ENABLE_NIL_PARSER = true

class Hash
  # this diff for hash will show the old one, and the newer one, as differences
  # e.g {"name"=>["old", "new"]}
  def diff_custom(other)
    (self.keys + other.keys).uniq.inject({}) do |memo, key|
      unless self[key] == other[key]
        if self[key].kind_of?(Hash) &&  other[key].kind_of?(Hash)
          memo[key] = self[key].diff(other[key])
        else
          memo[key] = [self[key], other[key]]
        end
      end
      memo
    end
  end
end
