require File.join(File.dirname(__FILE__), 'release_file')

class Environment

  def initialize
    @attributes = {}
    load_defaults
  end

  def method_missing(method_id, *args, &block)
    case method_id.to_s
    when /\A(.*)=\Z/
      @attributes[$1.to_sym] = args.first

    when /\A(.*)\?\Z/
      @attributes.key?($1.to_sym)

    else
      unless @attributes.key?(method_id)
        raise ArgumentError, "No value for #{method_id} defined"
      end
      value = @attributes[method_id.to_sym]
      return value.call if value.is_a?(Proc)
      value

    end
  end

  def load_release_file
    # Process the Releasefile and merge the attributes loaded
    release_file = ReleaseFile.new
    @attributes = @attributes.merge release_file.attributes
  end

  def load_capistrano_defaults(cap_config)
    # General cap info
    self.user = cap_config.fetch(:user, `git config user.name`.chomp)
    self.branch = cap_config.fetch(:branch, 'master')
    self.stage = cap_config.fetch(:stage, 'staging')
    self.repository = cap_config.fetch(:repository, nil)
    self.domain = cap_config.fetch(:domain, nil)
    self.display_name = cap_config.fetch(:display_name, 'Release Party')
  end

  def load_defaults
    self.from_address = 'Release Party <releaseparty@noreply.org>'
    self.smtp_address = 'localhost'
    self.smtp_port = 25
    self.subject = Proc.new {"A release of #{display_name} was released to #{domain}"}
    self.finished_stories = []
    self.known_bugs = []
    self.send_email = true
  end

end
