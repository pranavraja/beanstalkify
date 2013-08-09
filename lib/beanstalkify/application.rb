module Beanstalkify
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
        def deploy!(deployment, env)
            if deployment.deployed?
                puts "#{deployment.archive.version} is already uploaded."
            else
                deployment.upload!
                deployment.wait!
            end
            if env.status.empty?
                puts "Creating stack '#{@stack}' for #{deployment.archive.name}-#{deployment.archive.version}..."
                env.create!(deployment.archive, @stack, @config)
                env.wait!("Launching")
            else
                puts "Deploying #{deployment.archive.version} to #{env.name}..."
                env.deploy!(deployment.archive, @config)
                env.wait!("Updating")
            end
            puts "Done. Visit http://#{env.url} in your browser."
            DeploymentInfo.new env, deployment.archive
        end
    end
end
