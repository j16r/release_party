require 'spec/spec_helper'

describe Capistrano::ReleaseParty do

  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)
    @configuration.extend(Capistrano::ReleaseParty)
  end

  it 'defines release_party:finished' do
    @configuration.find_task('release_party:finished').should_not be_nil
  end

end
