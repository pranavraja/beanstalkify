require './lib/beanstalkify/archive'
require './lib/beanstalkify/environment'

describe Beanstalkify::Environment do
  before do
    allow(Beanstalkify::Beanstalk).to receive(:api).and_return @beanstalk_api = double
    @archive = Beanstalkify::Archive.new '/path/to/my/archive/app-name-version.zip'
    @env = Beanstalkify::Environment.new @archive, "Test"
    @settings = {something: 'enabled'}
  end
  
  describe 'creation' do
    it 'creates a new environment with params' do
      expect_beanstalk_create_environment
      @env.create! @archive, 'mastack', [], @settings
    end
  
    context 'when a CNAME is specified' do
      it 'creates a new environment with a cname, if available' do
        when_beanstalk_cname_availability_is 'ma-cname-1', true
        expect_beanstalk_create_environment(cname_prefix: 'ma-cname-1')
        @env.create! @archive, 'mastack', ['ma-cname-1'], @settings
      end

      it 'creates an environment without the cname, if the cname was unavailable' do
        when_beanstalk_cname_availability_is 'ma-cname-1', false
        expect_beanstalk_create_environment
        @env.create! @archive, 'mastack', ['ma-cname-1'], @settings
      end
    end
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
  
  describe 'waiting for a Beanstalk status change' do
    before(:each) do
      @env.stub :sleep  
    end
    
    it 'waits for the value to be different' do
      expect(@env).to receive(:status).exactly(3).times.and_return 'Launching', 'Launching', 'Running'
      @env.wait_until_status_is_not 'Launching'
    end
  
    it 'times out after a while but does not throw an error' do
      attempts = (Beanstalkify::Environment::STATUS_CHANGE_TIMEOUT / Beanstalkify::Environment::POLL_INTERVAL) + 1
      expect(@env).to receive(:status).exactly(attempts).times.and_return 'Unchanged'
      @env.wait_until_status_is_not 'Unchanged'
    end
  end
  
  describe 'waiting until healthy' do
    before(:each) do
      @env.stub :sleep  
    end
    
    it 'waits until health is green' do
      expect(@env).to receive(:healthy?).exactly(3).times.and_return false, false, true
      @env.wait_until_healthy
    end
    
    it 'times out after a while but does not throw an error' do
      attempts = (Beanstalkify::Environment::HEALTHY_TIMEOUT / Beanstalkify::Environment::POLL_INTERVAL) + 1
      expect(@env).to receive(:healthy?).exactly(attempts).times.and_return false
      @env.wait_until_healthy
    end
  end
  
  def when_beanstalk_describe_environments_returns(env_data)
    expect(@beanstalk_api).to receive(:describe_environments).with(
      environment_names: ["app-name-Test"],
      include_deleted: false
    ).and_return double(
      data: {environments: [env_data]}
    )
  end
  
  def expect_beanstalk_create_environment(additional_opts={})
    opts = {
      application_name: 'app-name',
      version_label: 'version',
      environment_name: 'app-name-Test',
      solution_stack_name: 'mastack',
      option_settings: @settings
    }.merge additional_opts
    expect(@beanstalk_api).to receive(:create_environment).with(opts).and_return nil
  end
  
  def when_beanstalk_cname_availability_is(cname_prefix, available)
    expect(@beanstalk_api).to receive(:check_dns_availability).with(cname_prefix: cname_prefix).and_return(available: available)
  end
end