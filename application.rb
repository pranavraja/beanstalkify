require './environment'
require './deploy'

class Application
  attr_accessor :stack, :config

  def initialize(stack)
    @stack = stack
    @config = {}
  end

  # config is an array of hashes:
  #   :namespace, :option_name, :value
  def configure!(config)
    errors = @beanstalk.validate_configuration_settings(config).data[:messages]
    if errors.count
      puts JSON.pretty_generate(errors)
      return
    end
    @config = config
  end

  # Deploy an archive to an environment. 
  # If the environment doesn't exist, it will be created.
  def deploy(archive, env)
    deployment = Deploy.new(archive)
    env = Environment.new(env)
    deployment.upload!
    if env.status == "none"
      env.create!(deployment.application, @stack, @config)
    else
      env.deploy!(deployment.application, @config)
    end
  end

  def switch_cnames(blue, green)
    @beanstalk.swap_environment_cnames({
      :source_environment_name => blue
      :destination_environment_name => green
    })
  end
end
