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

  it 'performs release_party:finished after deploy' do
    @configuration.should callback('release_party:finished').after('deploy')
  end

  it 'should lookup the project finished stories' do
    @configuration.find_and_execute_task('release_party:started')
    @configuration.find_and_execute_task('release_party:finished')
  end

  it 'should raise an error if we try to finish a release without starting it' do
    expect do
      @configuration.find_and_execute_task('release_party:finished')
    end.to raise_error(ArgumentError)
  end

end
