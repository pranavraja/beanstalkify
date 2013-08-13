require './lib/beanstalkify/archive'
require './lib/beanstalkify/environment'

describe Beanstalkify::Environment do
  before do
    archive = Beanstalkify::Archive.new '/path/to/my/archive/app-name-version.zip'
    @env = Beanstalkify::Environment.new archive, "Test"
  end

  it 'prepends the application name because environment names must be unique within an AWS account' do
    @env.name.should == "app-name-Test"
  end
end