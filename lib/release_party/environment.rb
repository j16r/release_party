require File.join(File.dirname(__FILE__), 'release_file')

class Environment

  attr :party

  def initialize(party)
    @party = party
    @variables = {}
  end

  def method_missing(method_id, *args, &block)
    case method_id.to_s
    when /\A(.*)=\Z/
      @variables[$1.to_sym] = args.first || block

    when /\A(.*)\?\Z/
      @variables[$1.to_sym]

    else
      key = method_id.to_sym
      value = @variables[key] || cap_config.fetch(key, defaults[key])
      return value.call if value.is_a?(Proc)
      value

    end
  end

  def load_release_file
    # Process the Releasefile and merge the variables loaded
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
