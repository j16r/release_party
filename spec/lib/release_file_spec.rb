require 'spec/spec_helper'

describe ReleaseFile do

  let(:path) { 'Releasefile' }

  describe '.new' do
    it 'raises an error if the file cannot be found' do
      expect do
        ReleaseFile.new ''
      end.to raise_error(ReleaseFile::FileNotFoundError)
    end

    it 'loads the file' do
      ReleaseFile.new 'Releasefile'
    end
  end

  context 'variables' do
    let(:file) { ReleaseFile.new 'Releasefile' }

    it 'has a project id of 295755' do
      file.variables[:project_id].should == 295755
    end
    
    it 'has an email notification to of "jebarker+releaseparty@gmail.com"' do
      file.variables[:email_notification_to].should == 'jebarker+releaseparty@gmail.com'
    end
  end

end
