# Lambdart

WTF is this? 

Lambdart is intended to be a simple, lightweight project-management CLI for AWS Lambda.  

If you aren't familiar with AWS Lambda, read [this](FIXME)

Managing lambda functions via the AWS console can be tedious, especially if you are making frequent code changes. The goals I had when creating Lambdart looked something like this:

* Allow fast and easy creation, configuration, deployment, and testing of Lambda functions from the command line with no dependence on the AWS console
* Provide at least a basic mechanism for separating Lambda code into "projects"
* Provide a basic mechanism for configuring different "environments" for Lambda functions
* Abstract away much of the role/permissions boilerplate
* Support any of the AWS Lambda supported runtimes (currently Node, Python and Java) and allow any combination of these runtimes within a project

If you intend to mostly use Lambda as an API server alternative via API Gateway, lambdart will work but it may not be the best choice. I'd recommend checking out [Serverless](https://github.com/serverless/serverless)

## Installation - WTF do I have to do to install it?

    $ gem install lambdart

It's that easy.

## Usage - WTF do I do with this thing?

First create a project

Next edit your project config

Now create a function

Now create a role for that function

Now edit the funciton config to include the role

Now sync the function

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

I am not a Ruby expert. I am not a Thor expert. I am not an AWS expert. Bug reports and pull requests are welcome and encouraged on GitHub at https://github.com/dknutsen/lambdart.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
