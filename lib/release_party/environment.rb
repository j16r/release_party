require File.join(File.dirname(__FILE__), 'release_file')

class Environment

  attr :party

  def initialize(party, config)
    @party = party
    @cap_config = config
    @variables = {}
  end

  def method_missing(method_id, *args, &block)
    case method_id.to_s
    when /\A(.*)=\Z/
      @variables[$1.to_sym] = args.first || block

    else
      key = method_id.to_sym
      value = if @variables.key?(key)
                @variables[key]
              else
                @cap_config.fetch(key, defaults[key])
              end
      return value.call if value.is_a?(Proc)
      value

    end
  end

  # Process the Releasefile and merge the variables loaded
  def load_release_file
    release_file = ReleaseFile.new
    @variables = @variables.merge release_file.variables
  end

  def defaults
    {
      :user => `git config user.name`.chomp,
      :branch => 'master',
      :stage => 'staging',
      :domain => 'http://releaseparty.org',
      :display_name => 'Release Party',
      :from_address => 'Release Party <releaseparty@noreply.org>',
      :smtp_address => 'localhost',
      :smtp_port => 25,
      :subject => Proc.new {"A release of #{display_name} was released to #{domain}"},
      :finished_stories => [],
      :known_bugs => [],
      :send_email => true,
      :template_engine => :haml,
      :deliver_stories => false,
    }
  end

end
