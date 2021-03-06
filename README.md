# Lambdart

## WTF is this? 

Lambdart is intended to be a simple, lightweight project-management CLI for AWS Lambda.  

If you aren't familiar with AWS Lambda, read [this](FIXME)

Managing lambda functions via the AWS console can be tedious, especially if you are making frequent code changes. The goals I had when creating Lambdart looked something like this:

* Allow fast and easy creation, configuration, deployment, and testing of Lambda functions from the command line with no dependence on the AWS console
* Provide at least a basic mechanism for separating Lambda code into "projects"
* Provide a basic mechanism for configuring different "environments" for Lambda functions
* Abstract away much of the role/permissions boilerplate
* Support any of the AWS Lambda supported runtimes (currently Node, Python and Java) and allow any combination of these runtimes within a project

If you intend to mostly use Lambda as an API server alternative using API Gateway, lambdart will work (eventually) but it may not be the best choice. I'd recommend checking out [Serverless](https://github.com/serverless/serverless)

## WTF do I have to do to install it?

    $ gem install lambdart

It's that easy.

## WTF should I do with this thing?

##### Create a project

    $ lambdart init <project name>

##### Edit secrets.yml
Next enter the new project directory and edit the `secrets.yml` file. You'll want to put your AWS access key, secret key, and region where the placeholders are. This will allow you to perform AWS operations via lambdart (which is built on the Ruby aws-sdk).

##### Edit project config
Now you'll want to edit your project config (`<project name>.lambdart`). All you'll want to do for starters is make sure you're ok with the AWS prefix (will be added to all functions and roles once they are synced to AWS)

##### Create a function
Now create a function (runtime is either `node`, `python` or `java`)

    $ lambdart create function <function name> <runtime>

##### Create a role
Now create a role for that function

    $ lambdart create role <role_name>

Edit the role if you desire. The default template includes permissions for all supported role permission types. Lambdart roles are permissive by default. This is convenient but can also be dangerous so it is highly recommended that you specify roles which grant only the necessary permissions and specify resources as explicitly as possible. 

##### Add the role to the function
Now edit the function config (`src/<function_name>/config.json`) to include the role.

##### Sync the function
Now sync the function

    $ lambdart sync function <function_name>



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

I am not a Ruby expert. I am not a Thor expert. I am not an AWS expert. Bug reports and pull requests are welcome and encouraged on GitHub at https://github.com/dknutsen/lambdart.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

