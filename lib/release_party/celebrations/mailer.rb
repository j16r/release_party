require File.join(File.dirname(__FILE__), '..', 'announce')
require File.join(File.dirname(__FILE__), '..', 'errors')

#
# Celebrate by sending out emails
#
module Celebrations
  class Mailer < Celebration
    include Announce

    class MailEnvironment
      attr :attachments

      def initialize(environment, mail)
        @environment = environment
        @mail = mail
        @attachments = []
      end

      def options_to_tag_attrs(options)
        options.inject([]) do |memo, (key, value)|
          memo << %{#{key}="#{value}"}
        end.join(' ')
      end

      def image_file(filename)
        path = File.join(File.dirname(@environment.template), filename)
        @mail.attachments.inline[File.basename(path)] = File.read(path)
        @attachments << attachment = @mail.attachments.inline[File.basename(path)]
        attachment.url
      end

      def image_tag(filename, options = {})
        %{<img src="#{image_file(filename)}" #{options_to_tag_attrs options}/>}
      end

      def method_missing(method_id, *args, &block)
        @environment.method_missing(method_id, *args, &block)
      end
    end

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

    def delete_image_part(parts, content_id)
      return if parts.nil?

      parts.each_with_index do |part, index|

        if part.content_disposition =~ /inline/i &&
          part.content_type =~ %r{^image/}i &&
          part.content_id == content_id

          return parts.delete_at(index)

        else
          delete_image_part(part.parts, content_id)

        end

      end
    end

    def deliver_notification
      mail = Mail.new
      mail.to = environment.email_notification_to
      mail.from = environment.from_address
      mail.subject = environment.subject

      mail_env = MailEnvironment.new(environment, mail)
      html = engine.render mail_env
      mail.part :content_type => 'multipart/related' do |part|
        part.part :content_type => 'text/html; charset=UTF-8', :body => html
        mail_env.attachments.each do |attachment|
          part.parts << delete_image_part(mail.parts, attachment.content_id)
        end
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
