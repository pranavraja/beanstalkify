require 'beanstalkify/beanstalk'

module Beanstalkify
    class Environment
        attr_accessor :name

        def initialize(archive, name)
            @name = [archive.app_name, name].join("-")
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

        # Assuming the archive has already been uploaded, 
        # create a new environment with the app deployed onto the provided stack.
        def create!(archive, stack, settings=[])
            @beanstalk.create_environment({
                :application_name => archive.app_name,
                :version_label => archive.version,
                :environment_name => self.name,
                :solution_stack_name => stack,
                :option_settings => settings
            })
        end

        def status
            e = describe_environment
            e ? e[:status] : ""
        end

        def url
            e = describe_environment
            e ? e[:cname] : ""
        end
        
        def healthy?
           e = describe_environment
           e ? e[:health] == 'Green' : false
        end

        # Wait for the status to change from `old_status` to something else
        def wait!(old_status)
            puts "Waiting for #{self.name} to finish #{old_status.downcase}..."
            while self.status == old_status
                print '.'              
                sleep 5
            end
            puts
        end
        
        private
        
        def describe_environment
            @beanstalk.describe_environments({
                :environment_names => [name],
                :include_deleted => false
            }).data[:environments].first
        end
    end
end
