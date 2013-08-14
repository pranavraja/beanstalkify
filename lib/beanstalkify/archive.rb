require 'aws-sdk'

module Beanstalkify
  class Archive
    attr_reader :app_name, :version
    
    def initialize(filename)
      @filename = filename
      @archive_name = File.basename(@filename)
      @app_name, hyphen, @version = File.basename(filename, '.*').rpartition("-")
    end

    def upload(beanstalk_api, s3_client=AWS::S3.new.client)
      if already_uploaded?(beanstalk_api)
        return puts "#{version} is already uploaded."
      end
      bucket = beanstalk_api.create_storage_location.data[:s3_bucket]
      upload_to_s3(s3_client, bucket)
      make_application_version_available_to_beanstalk(beanstalk_api, bucket)
    end
    
    private
  
    def upload_to_s3(s3_client, bucket)
      puts "Uploading #{@archive_name} to bucket #{bucket}..."
      s3_client.put_object(
        bucket_name: bucket, 
        key: @archive_name,
        data: File.open(@filename)
      )
    end
    
    def make_application_version_available_to_beanstalk(beanstalk_api, bucket)
      puts "Making version #{version} of #{app_name} available to Beanstalk..."
      beanstalk_api.create_application_version(
        application_name: app_name, 
        version_label: version,
        source_bundle: {
          s3_bucket: bucket,
          s3_key: @archive_name
        },
        auto_create_application: true
      )
    end
    
    def already_uploaded?(beanstalk_api)
      beanstalk_api.describe_application_versions(
        application_name: app_name,
        version_labels: [version]
      ).data[:application_versions].count > 0
    end
  end
end
