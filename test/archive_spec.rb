
require './archive'

describe Archive do
  archive = nil
  before do
    archive = Archive.new '/path/to/my/archive/appname-version.zip'
  end

  it 'should store the path' do
    archive.path.should eq('/path/to/my/archive/appname-version.zip')
  end

  it 'extracts the application name from the path' do
    archive.name.should eq('appname')
  end

  it 'extracts the version from the path' do
    archive.version.should eq('version')
  end

  it 'returns the filename of the archive' do
    archive.filename.should eq('appname-version.zip')
  end
end

