class ReleaseFile

  RELEASE_FILE = 'Releasefile'

  attr_reader :attributes

  def initialize
    @attributes = {}

    capfile_path = File.join(Dir.pwd, RELEASE_FILE)
    if File.exists?(capfile_path)
      eval File.read(capfile_path)
    else
      puts "Warning: No #{RELEASE_FILE} found, you should put one in your project root."
    end
  end

  def method_missing(method_id, *args, &block)
    @attributes[method_id.to_sym] = *args
  end

end
