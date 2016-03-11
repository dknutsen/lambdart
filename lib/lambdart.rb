require "lambdart/version"
require "lambdart/cli"

module Lambdart
  # Your code goes here...
  autoload :Lambda, 'lambdart/lambda'
  autoload :S3, 'lambdart/s3'
  autoload :Manager, 'lambdart/manager'
  autoload :Iam, 'lambdart/iam'
  
end


