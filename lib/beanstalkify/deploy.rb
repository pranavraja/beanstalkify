require 'beanstalkify/archive'
require 'beanstalkify/beanstalk'
require 'aws-sdk'

module Beanstalkify
    class Deploy
        attr_accessor :beanstalk, :archive

        def initialize(path)
            @archive = Archive.new(path)
            @beanstalk = Beanstalk.api
        end

        def bucket
            @beanstalk.create_storage_location.data[:s3_bucket]
        end

        def upload!
            client = AWS::S3.new.client
            bucket = self.bucket
            puts "Uploading #{@archive.filename} to bucket #{bucket}..."
            client.put_object({ :bucket_name => bucket, :key => @archive.filename, :data => File.open(@archive.path) })
            puts "Creating #{@archive.name} - #{@archive.version} in beanstalk"
            @beanstalk.create_application_version({ 
                :application_name => @archive.name, 
                :version_label => @archive.version,
                :source_bundle => {
                    :s3_bucket => bucket,
                    :s3_key => @archive.filename
                },
                :auto_create_application => true
            })
        end

        def deployed?
            @beanstalk.describe_application_versions({
                :application_name => @archive.name,
                :version_labels => [@archive.version]
            }).data[:application_versions].count > 0
        end

        def wait!
            while not self.deployed?
                puts "Waiting for #{@archive.version} to be available..."
                sleep 10
            end
        end
    end
end
