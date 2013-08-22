require 'beanstalkify/beanstalk'

module Beanstalkify
  class Environment
    POLL_INTERVAL = 5
    STATUS_CHANGE_TIMEOUT = 1200
    HEALTHY_TIMEOUT = 120
    
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
        version_label: app.version,
        environment_name: self.name,
        option_settings: settings
      })
    end

    # Assuming the archive has already been uploaded, 
    # create a new environment with the app deployed onto the provided stack.
    # Attempts to use the first available cname in the cnames array.
    def create!(archive, stack, cnames, settings=[])
      params = {
        application_name: archive.app_name,
        version_label: archive.version,
        environment_name: self.name,
        solution_stack_name: stack,
        option_settings: settings
      }
      cnames.each do |c|
        if dns_available(c)
          params[:cname_prefix] = c
          break
        else
          puts "CNAME #{c} is unavailable."
        end
      end
      @beanstalk.create_environment(params)
    end

    def dns_available(cname)
      @beanstalk.check_dns_availability({
        cname_prefix: cname
      })[:available]
    end

    def url
      e = describe_environment
      e ? e[:cname] : ""
    end
  
    def healthy?
      e = describe_environment
      e ? e[:health] == 'Green' : false
    end
  
    def status
      e = describe_environment
      e ? e[:status] : ""
    end
    
    def wait_until_status_is_not(old_status)
      puts "Waiting for #{self.name} to finish #{old_status.downcase}..."      
      wait_until -> { status != old_status }, STATUS_CHANGE_TIMEOUT
    end
    
    def wait_until_healthy
      puts "Waiting until #{self.name} is healthy..."
      wait_until -> { healthy? }, HEALTHY_TIMEOUT
    end
    
    private
    
    def describe_environment
      @beanstalk.describe_environments({
        environment_names: [name],
        include_deleted: false
      }).data[:environments].first
    end
    
    def wait_until(condition, timeout)
      until condition.call or timeout <= 0
        print '.'
        sleep POLL_INTERVAL
        timeout -= POLL_INTERVAL
      end
      puts
    end
  end
end
