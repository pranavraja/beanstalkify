require './deploy'

describe Deploy do
    deploy = nil
    before do
        deploy = Deploy.new('/Users/pmoney/temp/foo-1.0.zip')
    end

    it 'should get the s3 bucket' do
        #puts deploy.bucket
    end

    it 'should upload the application' do
        #puts deploy.upload!
    end

    it 'should create a new environment with the application' do
        #puts deploy.create!("test3", "64bit Amazon Linux running Node.js").data
    end

    it 'should get the status of an environment' do
        #puts deploy.status("test3")
    end
end
