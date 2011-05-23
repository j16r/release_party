require 'spec/spec_helper'

describe Capistrano::ReleaseParty do

  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)
    @configuration.extend(Capistrano::ReleaseParty)
  end

  it 'defines release_party:started' do
    @configuration.find_task('release_party:started').should_not be_nil
  end

  it 'defines release_party:finished' do
    @configuration.find_task('release_party:finished').should_not be_nil
  end

  describe 'release_party:started' do

    it 'creates an instance of all the celebrations' do
      task = @configuration.find_and_execute_task('release_party:started')
      task.instance_variable_get('@env').should_not be_nil
    end

  end

end
