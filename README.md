
[AWS Elastic Beanstalk](http://aws.amazon.com/elasticbeanstalk/) automation. A work in progress.

# Prerequisites

- Ruby 1.9

# Installation

    gem install beanstalkify

Create a file called `credentials.yml`, with the following format:

    access_key_id: A98KJHBLABLABLA
    secret_access_key: dkuU90kmySuperSecretKey
    region: us-east-1

# Running

    beanstalkify -k credentials.yml -a app-version.zip -s "64bit Amazon Linux running Node.js" -e env [-c config.yml]

Should do the following

- Connect to aws using the credentials in `credentials.yml`
- Publish `app-version.zip` to s3
- Ensure that a beanstalk application called 'app' exists, and add a version called 'version', linked to the archive in that s3 bucket
- Ensure that the environment `env` exists (with optional settings overrides in `config.yml` - see below), running the specified stack.
- Deploy the provided version of the application into `env`
- Report progress. When complete report the URL where the app can be hit (note: this will be the URL of the ELB).

# Settings overrides

An example `config.yml`:

```yaml
-
    namespace: 'aws:autoscaling:asg'
    option_name: Availability Zones
    value: Any 2
-
    namespace: 'aws:autoscaling:launchconfiguration'
    option_name: InstanceType
    value: m1.small
-
    namespace: 'aws:autoscaling:launchconfiguration'
    option_name: EC2KeyName
    value: MyAwesomeEC2-dev
```

# Running the somewhat useless tests
    
    bundle exec rspec test

# TODO

- Tests around error handling
- Provide some blue-green deployment integrated with health checks, using the `swap_environment_cnames` feature of the AWS SDK.

