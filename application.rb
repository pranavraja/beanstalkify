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
    def deploy!(archive, environment_name)
        deployment = Deploy.new(archive)
        env = Environment.new(environment_name)
        if deployment.deployed?
            puts "#{deployment.application.version} is already uploaded."
        else
            deployment.upload!
            deployment.wait!
        end
        if env.status.empty?
            puts "Creating stack '#{@stack}' for #{deployment.application.name}-#{deployment.application.version}..."
            env.create!(deployment.application, @stack, @config)
        else
            puts "Deploying #{deployment.application.version} to #{environment_name}..."
            env.deploy!(deployment.application, @config)
        end
        env.wait!
        puts "Done. Visit http://#{env.url} in your browser."
    end
end
