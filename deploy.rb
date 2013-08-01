require './archive'
require './beanstalk'
require 'aws-sdk'

class Deploy
    attr_accessor :beanstalk, :application

    def initialize(path)
        @application = Archive.new(path)
        @beanstalk = Beanstalk.api
    end

    def bucket
        @beanstalk.create_storage_location.data[:s3_bucket]
    end

    def upload!
        client = AWS::S3.new.client
        bucket = self.bucket
        puts "Uploading #{@application.filename} to bucket #{bucket}..."
        client.put_object({ :bucket_name => bucket, :key => @application.filename, :data => File.open(@application.path) })
        puts "Creating #{@application.name} - #{@application.version} in beanstalk"
        @beanstalk.create_application_version({ 
            :application_name => @application.name, 
            :version_label => @application.version,
            :source_bundle => {
                :s3_bucket => bucket,
                :s3_key => @application.filename
            },
            :auto_create_application => true
        })
    end

    def deployed?
        @beanstalk.describe_application_versions({
            :application_name => @application.name,
            :version_labels => [@application.version]
        }).data[:application_versions].count > 0
    end

    def wait!
        while not self.deployed?
            puts "Waiting for #{@application.version} to be available..."
            sleep 10
        end
    end
end

