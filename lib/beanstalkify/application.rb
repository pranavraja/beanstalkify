module Beanstalkify
    class Application
        attr_accessor :stack, :config

        # config is an array of hashes:
        #   :namespace, :option_name, :value
        def initialize(stack, cnames, config)
            @stack = stack
            @cnames = cnames.split(',')
            @config = config.map { |c| Hash[c.map { |k, v| [k.to_sym,v]}] }
        end

        # Deploy an archive to an environment. 
        # If the environment doesn't exist, it will be created.
        def deploy!(archive, env)
            archive.upload(Beanstalk.api)
            
            if env.status.empty?
                puts "Creating stack '#{@stack}' for #{archive.app_name}-#{archive.version}..."
                env.create!(archive, @stack, @cnames, @config)
                env.wait_until_status_is_not "Launching"
            else
                puts "Deploying #{archive.version} to #{env.name}..."
                env.deploy!(archive, @config)
                env.wait_until_status_is_not "Updating"
            end
            
            env.wait_until_healthy
            puts "Done. Visit http://#{env.url} in your browser."
            DeploymentInfo.new env, archive
        end
    end
end
