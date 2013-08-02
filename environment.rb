require './beanstalk'

class Environment
    attr_accessor :name

    def initialize(name)
        @name = name
        @beanstalk = Beanstalk.api
    end

    # Assuming the provided app has already been uploaded,
    # update this environment to the app's version
    # Optionally pass in a bunch of settings to override
    def deploy!(app, settings=[])
        @beanstalk.update_environment({
            :version_label => app.version,
            :environment_name => self.name,
            :option_settings => settings
        })
    end

    # Assuming the app has already been uploaded, 
    # create a new environment with the app deployed onto the provided stack.
    def create!(app, stack, settings=[])
        @beanstalk.create_environment({
            :application_name => app.name,
            :version_label => app.version,
            :environment_name => self.name,
            :solution_stack_name => stack,
            :option_settings => settings
        })
    end

    def status
        envs = @beanstalk.describe_environments({
            :environment_names => [self.name],
            :include_deleted => false
        }).data[:environments]
        e = envs.first
        e ? e[:status] : ""
    end

    def url
        envs = @beanstalk.describe_environments({
            :environment_names => [self.name]
        }).data[:environments]
        e = envs.first
        e ? e[:endpoint_url] : ""
    end

    # Wait for the status to change from `old_status` to something else
    def wait!(old_status)
        while self.status == old_status
            puts "#{self.name} is still #{old_status}..."
            sleep 20
        end
    end
end
