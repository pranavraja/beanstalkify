
module Beanstalkify
    class Archive
        attr_accessor :path

        def initialize(path)
            @path = path
        end

        def name
            f = filename
            f[0..f.rindex('-')-1]
        end

        def version
            File.basename(@path, '.*').split('-')[-1]
        end

        def filename
            File.basename(@path)
        end
    end
end
