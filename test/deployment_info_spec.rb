require './lib/beanstalkify/deployment_info'
require './lib/beanstalkify/archive'

describe Beanstalkify::DeploymentInfo do
  before(:each) do
    environment = double(name: 'TestEnv', url: 'http://env.url')
    archive = Beanstalkify::Archive.new('test-website-1.0.1.zip')
    @info = Beanstalkify::DeploymentInfo.new(environment, archive)
  end
  
  it 'dumps useful info to a YAML string' do
    expected = {
      'app_name'    => 'test-website',
      'app_version' => '1.0.1',
      'env_name'    => 'TestEnv',
      'env_url'     => 'http://env.url'
    }
    @info.to_yaml.should == expected.to_yaml
  end
end

