require 'aws-sdk'

class Beanstalk
    def self.configure!(config={})
        # Convert string keys to symbols
        @@config = Hash[config.map{|(k,v)| [k.to_sym,v]}]
    end
    def self.api
        AWS.config(@@config)
        AWS::ElasticBeanstalk.new.client
    end
end
