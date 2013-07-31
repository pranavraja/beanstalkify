require 'aws-sdk'
require './archive'

class Deploy
  attr_accessor :beanstalk, :application

  def initialize(path)
    @application = Archive.new(path)
    @beanstalk = AWS::ElasticBeanstalk.new.client
  end

  def bucket
    @beanstalk.create_storage_location.data[:s3_bucket]
  end

  def upload!
    client = AWS::S3.new.client
    bucket = self.bucket
    client.put_object({ :bucket_name => bucket, :key => @application.filename, :data => @application.path })
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
end

