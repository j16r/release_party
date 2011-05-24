require 'rubygems'
require 'capistrano'

require File.join(File.dirname(__FILE__), 'announce')
require File.join(File.dirname(__FILE__), 'environment')
require File.join(File.dirname(__FILE__), 'celebration')

Dir[File.join(File.dirname(__FILE__), 'celebrations', '*.rb')].each do |file|
  require file
end

module Capistrano::ReleaseParty
  include Announce

  # Singleton instance of the release party environment
  def self.instance(party = nil, &block)
    return @env unless @env.nil?

    raise ArgumentError, "Release finished without being started" if party.nil?

    @env = Environment.new party
    yield(@env) if block_given?
    @env
  end

  def self.extended(configuration)
    configuration.load do

      before 'deploy', 'release_party:starting'
      after 'deploy',  'release_party:finished'

      namespace :release_party do
        task :starting do

          env = Capistrano::ReleaseParty.instance(Capistrano::ReleaseParty) do |environment|
            begin
              environment.load_release_file
            rescue ReleaseFile::FileNotFoundError => error
              announce error.message
            end
          end

          announce "Beginning deployment, project details obtained."

          # Record when the release began
          env.release_started = Time.now

          # Load all the celebrations
          env.celebrations = \
            Celebration.celebrations.collect do |celebration_class|
              begin
                celebration_class.new(env).tap(&:before_deploy)

              rescue LoadError => error
                announce "Unable to load #{celebration_class}, message: #{error.message} you may have to install a gem"

              rescue ArgumentError => error
                announce error.message

              end
            end.compact

          self
          
        end

        task :finished do
          env = Capistrano::ReleaseParty.instance

          announce "Performing post deploy celebrations!"

          # Record when the release finished
          env.release_finished = Time.now

          # Do after deploy
          env.celebrations.each(&:after_deploy)

          self
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::ReleaseParty)
end
