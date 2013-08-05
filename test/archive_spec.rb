
require './lib/beanstalkify/archive'

describe Beanstalkify::Archive do
  archive = nil
  before do
    archive = Beanstalkify::Archive.new '/path/to/my/archive/app-name-version.zip'
  end

  it 'should store the path' do
    archive.path.should eq('/path/to/my/archive/app-name-version.zip')
  end

  it 'extracts the application name from the path' do
    archive.name.should eq('app-name')
  end

  it 'extracts the version from the path' do
    archive.version.should eq('version')
  end

  it 'returns the filename of the archive' do
    archive.filename.should eq('app-name-version.zip')
  end
end

