
[AWS Elastic Beanstalk](http://aws.amazon.com/elasticbeanstalk/) automation. A work in progress, no features implemented yet.

# Goals

    beanstalkify -k aws.key -a app-version.zip -s "64bit Amazon Linux running Node.js" -e env

Should do the following

- Connect to aws using the credentials in `aws.key`
- Publish `app-version.zip` to s3
- Ensure that a beanstalk application called 'app' exists, and add a version called 'version', linked to the archive in that s3 bucket
- Ensure that the environment `env` exists, running the specified stack
- Deploy the provided version of the application into `env`
- Report progress. When complete report the URL where the app can be hit.

And eventually the following

- Allow setting overrides through a `config.yml` or similar file.
- Provide some blue-green deployment integrated with health checks, using the `swap_environment_cnames` feature of the AWS SDK.

# Prerequisites

- Ruby 1.9
- bundler

# Setup

    bundle install

You'll need to set some environment variables to start playing around with this API:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

# Running the somewhat useless tests
    
    bundle exec rspec test
