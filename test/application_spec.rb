require './application'
require './environment'

describe Application do
    it 'should deploy an application' do
        application = Application.new('64bit Amazon Linux running Node.js')
        application.deploy!('/Users/pmoney/tmp/App-64fc96e.zip', 'test-env')
    end
end
