module Beanstalkify
  class DeploymentInfo
    def initialize(environment, archive)
      @environment, @archive = environment, archive
    end
    
    def to_yaml
      {
        'app_name'    => @archive.app_name,
        'app_version' => @archive.version,
        'env_name'    => @environment.name,
        'env_url'     => @environment.url
      }.to_yaml
    end
  end
end