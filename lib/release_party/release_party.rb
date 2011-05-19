require 'capistrano'
require 'pivotal-tracker'
require 'mail'
require 'haml'

require File.join(File.dirname(__FILE__), 'environment')

module Capistrano::ReleaseParty

  def self.extended(configuration)
    configuration.load do

      after 'deploy', 'release_party:finished'

      namespace 'release_party' do
        task 'started' do
          @env = Environment.new

          # Record when the release began
          @env.release_started = Time.now

          @env.load_capistrano_defaults(self)
          @env.load_release_file
        end

        task 'finished' do
          raise ArgumentError, "Release finished without being started" if @env.nil?

          # Record when the release finished
          @env.release_finished = Time.now

          load_tracker_progress @env
          load_git_progress @env

          if @env.send_email
            body = load_email_content @env
            deliver_notification(@env, body)
          end

        end
      end
    end
  end

  def load_git_progress(env)

  end

  def load_email_content(env)
    # Mail a release party notice to someone?
    template = env.template
    engine = \
      if template && FileTest.exists?(template)
        Haml::Engine.new(File.read(template))
      end

    if engine
      engine.render env
    else
      'Hello'
    end
  end

  def load_tracker_progress(env)
    # For pivotal info
    if env.project_id? && env.project_api_key?
      PivotalTracker::Client.token = env.project_api_key

      begin
        project = PivotalTracker::Project.find(env.project_id)
      rescue RestClient::Request::Unauthorized => e
        puts "Unable to authenticate with pivotal, perhaps your API key is wrong. Message: #{e.message}"
      end

      env.instance_eval do
        self.finished_stories = project.stories.all(:state => 'finished')
        self.known_bugs = project.stories.all(:state => ['unstarted', 'started'], :story_type => 'bug')
      end
    end
  end

  def deliver_notification(env, body)
    Mail.defaults do
      delivery_method :smtp,
        :address => env.smtp_address,
        :port => env.smtp_port
    end
    Mail.deliver do
      from      env.from_address
      to        env.email_notification_to
      subject   env.subject
      html_part do
        content_type 'text/html; charset=UTF-8'
        body body
      end
    end
  end

end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Configuration.instance)
end
