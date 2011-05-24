require 'spec/spec_helper'

describe Capistrano::ReleaseParty do

  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)
    @configuration.extend(Capistrano::ReleaseParty)
  end

  it 'defines release_party:starting' do
    @configuration.find_task('release_party:starting').should_not be_nil
  end

  it 'defines release_party:finished' do
    @configuration.find_task('release_party:finished').should_not be_nil
  end

  it 'performs release_party:finished after deploy' do
    @configuration.should callback('release_party:finished').after('deploy')
  end

  describe 'release_party:starting' do

    it 'creates an instance of all the celebrations' do
      task = @configuration.find_and_execute_task('release_party:starting')
      Capistrano::ReleaseParty.instance.celebrations.size.should > 0
    end

  end

end
