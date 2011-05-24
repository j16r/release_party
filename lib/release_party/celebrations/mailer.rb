require File.join(File.dirname(__FILE__), '..', 'announce')
require File.join(File.dirname(__FILE__), '..', 'errors')

#
# Celebrate by sending out emails
#
module Celebrations
  class Mailer < Celebration
    include Announce

    attr :engine

    def initialize(env)
      super env
      arguments_required(:template_engine, :template, :smtp_address, :smtp_port,
                        :from_address, :email_notification_to, :subject)

      require 'mail'

      template = env.template
      raise ArgumentError, "Missing template file #{template}" unless File.exists?(template)

      @engine = \
        case environment.template_engine
        when :haml
          require 'haml'
          Haml::Engine.new(File.read(template))

        when :erb
          require 'erb'
          ERB.new(File.read(template))

        else
          raise ArgumentError, "Unsupported template engine #{environment.template_engine}"
        end

      address = environment.smtp_address
      port = environment.smtp_port
      domain = environment.smtp_domain
      Mail.defaults do
        delivery_method :smtp, :address => address, :port => port, :domain => domain
      end
    end

    def after_deploy
      deliver_notification
    end

  private #######################################################################

    def deliver_notification
      mail = Mail.new
      mail.to = environment.email_notification_to
      mail.from = environment.from_address
      mail.subject = environment.subject
      html = engine.render environment 
      mail.html_part do
        content_type 'text/html; charset=UTF-8'
        body html
      end

      announce "Delivering deployment notice to #{environment.email_notification_to.inspect}"
      mail.deliver!

    rescue *SMTP_SERVER_ERRORS => error
      announce "Unable to deliver deployment notice: #{error.message}"

    else
      announce "Deployment notice sent!"

    end

  end
end
