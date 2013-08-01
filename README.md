
[AWS Elastic Beanstalk](http://aws.amazon.com/elasticbeanstalk/) automation. A work in progress.

# Prerequisites

- Ruby 1.9
- bundler

# Setup

    bundle install

Create a file called `credentials.yml`, with the following format:

    access_key_id: youraccesskey
    secret_access_key: yoursecretkey
    region: yourregion

# Running

    beanstalkify -k credentials.yml -a app-version.zip -s "64bit Amazon Linux running Node.js" -e env

Should do the following

- Connect to aws using the credentials in `credentials.yml`
- Publish `app-version.zip` to s3
- Ensure that a beanstalk application called 'app' exists, and add a version called 'version', linked to the archive in that s3 bucket
- Ensure that the environment `env` exists, running the specified stack
- Deploy the provided version of the application into `env`
- Report progress. When complete report the URL where the app can be hit.

# Running the somewhat useless tests
    
    bundle exec rspec test

# TODO

- Tests around error handling
- Allow setting overrides through a `config.yml` or similar file.
- Provide some blue-green deployment integrated with health checks, using the `swap_environment_cnames` feature of the AWS SDK.

