require 'capistrano'
require 'pivotal-tracker'
require 'mail'

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

          begin

            # Record when the release finished
            @env.release_finished = Time.now

            load_git_progress @env

            load_tracker_progress @env

            # Do pivotal story delivery
            if @env.deliver_stories
              commit_tracker_progress @env
            end

            # Send an email notification
            if @env.send_email
              body = load_email_content @env
              deliver_notification(@env, body)
            end

          #rescue ArgumentError => error
          #  puts "ERROR: #{error.message}"
          end
        end
      end
    end
  end

  def commit_tracker_progress(env)

  end

  def load_git_progress(env)

  end

  def load_email_content(env)
    arguments_required env, :template_engine, :template

    template = env.template
    raise ArgumentError, "Missing template file #{template}" unless File.exists?(template)

    engine = \
      case env.template_engine
      when :haml
        load_haml
        Haml::Engine.new(File.read(template))

      when :erb
        load_erb
        ERB.new(File.read(template))

      else
        raise ArgumentError, "Unsupported template engine #{env.template_engine}"
      end

    engine.render env
  end

  def load_tracker_progress(env)
    arguments_required env, :project_id, :project_api_key

    PivotalTracker::Client.token = env.project_api_key

    begin
      env.project = PivotalTracker::Project.find(env.project_id)
    rescue RestClient::Request::Unauthorized => e
      puts 'Unable to authenticate with pivotal, perhaps your API key is wrong.' +
        "Message: #{e.message}"
    end

    env.instance_eval do
      self.finished_stories = \
        project.stories.all(:state => 'finished')
      self.known_bugs = \
        project.stories.all(:state => ['unstarted', 'started'], :story_type => 'bug')
    end
  end

  def deliver_notification(env, body)
    arguments_required env,
      :smtp_address, :smtp_port, :smtp_domain, :from_address,
      :email_notification_to, :subject

    Mail.defaults do
      delivery_method :smtp,
        :address => env.smtp_address,
        :port => env.smtp_port,
        :domain => env.smtp_domain
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

  def arguments_required(env, *arguments)
    missing = arguments.reject do |argument|
      env.send("#{argument}?".to_sym)
    end
    unless missing.empty?
      raise ArgumentError, "Parameters #{missing.join(', ')} must be defined"
    end
  end

  def load_haml
    require 'haml'
  rescue LoadError => error
    raise ArgumentError,
      'Unable to load HAML, you need to make sure the haml gem is installed ' 
      'if it is specified as the template engine'
  end

  def load_erb
    require 'erb'
  rescue LoadError => error
    raise ArgumentError,
      'Unable to load ERB, you need to make sure the erb gem is installed ' 
      'if it is specified as the template engine'
  end

end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Configuration.instance)
end
