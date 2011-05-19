require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

# Include the spec support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Include the project code
require File.join(File.dirname(__FILE__), '..', 'lib', 'release_party')
