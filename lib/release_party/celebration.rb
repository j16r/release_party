#
# Celebration is effectively an abstract class that handles before and after deploy callbacks
#
class Celebration

  attr :environment

  def self.inherited(subclass)
    (@@celebrations ||= []) << subclass
  end

  def initialize(environment)
    @environment = environment
  end

  def tasks
    []
  end

  def before_deploy
  end

  def after_deploy
  end

protected #####################################################################

  def announce(*args)
    environment.party.announce *args
  end

  def self.celebrations
    @@celebrations
  end

  # Helper to check that all arguments required for a particular task
  # are supplied
  def arguments_required(*arguments)
    missing = arguments.reject do |argument|
      environment.send(argument.to_sym)
    end
    unless missing.empty?
      raise ArgumentError, "Parameters #{missing.join(', ')} must be defined"
    end
  end

end
