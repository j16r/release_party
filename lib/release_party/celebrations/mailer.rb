require File.join(File.dirname(__FILE__), '..', 'announce')

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
      domain = environment.smtp_domain? && environment.smtp_domain
      Mail.defaults do
        delivery_method :smtp, :address => address, :port => port, :domain => domain
      end
    end

    def after_deploy
      deliver_notification
    end

  private #######################################################################

    def deliver_notification
      announce "Delivering deployment notice to #{environment.email_notification_to.inspect}"
      body = engine.render environment
      from = environment.from_address
      to = environment.email_notification_to
      subject = environment.subject
      Mail.deliver do
        from      from
        to        to
        subject   subject
        html_part do
          content_type 'text/html; charset=UTF-8'
          body body
        end
      end
      announce "Deployment notice sent!"
    end

  end
end
