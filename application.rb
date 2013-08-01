require './environment'
require './deploy'

class Application
    attr_accessor :stack, :config

    # config is an array of hashes:
    #   :namespace, :option_name, :value
    def initialize(stack, config)
        @stack = stack
        @config = config.map { |c| Hash[c.map { |k, v| [k.to_sym,v]}] }
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
            env.wait!("Launching")
        else
            puts "Deploying #{deployment.application.version} to #{environment_name}..."
            env.deploy!(deployment.application, @config)
            env.wait!("Updating")
        end
        puts "Done. Visit http://#{env.url} in your browser."
    end
end
