require './lib/beanstalkify/archive'
require './lib/beanstalkify/environment'

describe Beanstalkify::Environment do
  before do
    allow(Beanstalkify::Beanstalk).to receive(:api).and_return @beanstalk_api = double
    archive = Beanstalkify::Archive.new '/path/to/my/archive/app-name-version.zip'
    @env = Beanstalkify::Environment.new archive, "Test"
  end

  it 'prepends the application name because environment names must be unique within an AWS account' do
    @env.name.should == "app-name-Test"
  end
  
  it 'exposes the Beanstalk status' do
    when_beanstalk_describe_environments_returns(status: 'Uncertain')
    @env.status.should == 'Uncertain'
  end
  
  it 'exposes the Beanstalk CNAME URL' do
    when_beanstalk_describe_environments_returns(cname: 'http://cname.elasticbeanstalk.com')
    @env.url.should == 'http://cname.elasticbeanstalk.com'
  end
  
  it 'is healthy when Beanstalk reports that it is green' do
    when_beanstalk_describe_environments_returns(health: 'Red')
    @env.should_not be_healthy
    when_beanstalk_describe_environments_returns(health: 'Green')
    @env.should be_healthy
  end
  
  def when_beanstalk_describe_environments_returns(env_data)
    expect(@beanstalk_api).to receive(:describe_environments).with(
      environment_names: ["app-name-Test"],
      include_deleted: false
    ).and_return double(
      data: {environments: [env_data]}
    )
  end
end