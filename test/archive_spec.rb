require './lib/beanstalkify/archive'

describe Beanstalkify::Archive do
  ARCHIVE_FILENAME = '/path/to/my/archive/app-name-version.zip'
  
  before do
    @archive = Beanstalkify::Archive.new ARCHIVE_FILENAME
  end
  
  describe 'parsing the filename' do
    it 'extracts the application name from the filename' do
      @archive.app_name.should eq('app-name')
    end

    it 'extracts the archive version from the filename' do
      @archive.version.should eq('version')
    end
  end
  
  describe 'uploading to AWS' do
    before(:each) do
      @beanstalk_api = double(
        create_storage_location: double(
          data: {s3_bucket: 'mah bukkit'}
        )
      ).as_null_object
      @s3_client = double.as_null_object
      allow(File).to receive(:open).with(ARCHIVE_FILENAME).and_return("fake archive file contents")
    end
    
    it 'knows if it has already been uploaded' do
      when_beanstalk_describe_application_versions_returns([])
      @archive.send(:already_uploaded?, @beanstalk_api).should be_false
      when_beanstalk_describe_application_versions_returns(["some version or other"])
      @archive.send(:already_uploaded?, @beanstalk_api).should be_true      
    end
    
    context "when it has already been uploaded" do
      before(:each) do
        allow(@archive).to receive(:already_uploaded?).and_return true
      end
      
      it 'does not re-upload' do
        expect(@s3_client).to_not receive(:put_object)        
        expect(@beanstalk_api).to_not receive(:create_application_version)
        @archive.upload @beanstalk_api, @s3_client
      end
    end
    
    context "when it hasn't already been uploaded" do
      before(:each) do
        allow(@archive).to receive(:already_uploaded?).and_return false
      end
      
      it 'uploads the file to S3' do
        expect(@s3_client).to receive(:put_object).with(
          bucket_name: 'mah bukkit', 
          key: 'app-name-version.zip', 
          data: "fake archive file contents"
        )
        @archive.upload @beanstalk_api, @s3_client
      end
    
      it 'creates an available application version' do
        expect(@beanstalk_api).to receive(:create_application_version).with(
          application_name: "app-name", 
          version_label: "version",
          source_bundle: {
            s3_bucket: "mah bukkit",
            s3_key: "app-name-version.zip"
          },
          auto_create_application: true
        )
        @archive.upload @beanstalk_api, @s3_client
      end
    end
  end
  
  def when_beanstalk_describe_application_versions_returns(versions)
    expect(@beanstalk_api).to receive(:describe_application_versions).with(
      application_name: "app-name",
      version_labels: ["version"]
    ).and_return(double(data: {application_versions: versions}))
  end
end

