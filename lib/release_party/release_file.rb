#
# Release file just gives us some handy short hand for defining variables
# inside a file, e.g:
#
# x 1
# y 2
#
# Sets the configuration variables x and y to 1 and 2 respectively, plus it
# supports blocks and comments
#
class ReleaseFile

  FileNotFoundError = Class.new(RuntimeError)

  RELEASE_FILE = 'Releasefile'
  RELEASE_PATH = File.join(Dir.pwd, RELEASE_FILE)

  attr_reader :variables

  def initialize(path = RELEASE_PATH)
    @variables = {}

    raise FileNotFoundError, "No Releasefile found name at #{path}" unless File.exists?(path)
    eval File.read(path)
  end

  def method_missing(method_id, *args, &block)
    @variables[method_id.to_sym] = args.first || block
  end

end
