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

  def self.extended(configuration)
    configuration.load do

      before 'deploy', 'release_party:started'
      after 'deploy', 'release_party:finished'

      namespace 'release_party' do
        task 'started' do

          if @env.nil?
            # Load all the variables, first the defaults, then the values from
            # the Capfile , then anything in the Releasefile
            @env = Environment.new(Capistrano::ReleaseParty)
            @env.load_defaults
            @env.load_capistrano_defaults(configuration)
            begin
              @env.load_release_file
            rescue ReleaseFile::FileNotFoundError => e
              announce e.message
            end
          end

          announce "Beginning deployment, project details obtained."

          # Record when the release began
          @env.release_started = Time.now

          # Load all the celebrations
          @env.celebrations = \
            Celebration.celebrations.collect do |celebration_class|
              begin
                celebration_class.new(@env).tap(&:before_deploy)

              rescue LoadError => error
                announce "Unable to load #{celebration} you need the #{error} gem"

              rescue ArgumentError => error
                announce error.message

              end
            end.compact

          self
          
        end

        task 'finished' do
          raise ArgumentError, "Release finished without being started" if @env.nil?

          announce "Performing post deploy celebrations!"

          # Record when the release finished
          @env.release_finished = Time.now

          # Do after deploy
          @env.celebrations.each(&:after_deploy)

          self
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Configuration.instance)
end
