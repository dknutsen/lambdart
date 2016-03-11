require "lambdart/version"
require "lambdart/cli"
require "lambdart/iam"
require "lambdart/lambda"
require "lambdart/manager"
require "lambdart/s3"
require "lambdart/sync"
require "lambdart/utils"

require 'yaml'
require 'aws-sdk'

creds = YAML.load(File.read((Manager.find_project_root+'secrets.yml')).to_s)
$lambda_client = Aws::Lambda::Client.new(
  access_key_id: creds['AWS_ACCESS_KEY_ID'],
  secret_access_key: creds['AWS_SECRET_ACCESS_KEY'],
  region: creds['AWS_DEFAULT_REGION']
)
$s3_client = Aws::S3::Client.new(
  access_key_id: creds['AWS_ACCESS_KEY_ID'],
  secret_access_key: creds['AWS_SECRET_ACCESS_KEY'],
  region: creds['AWS_DEFAULT_REGION']
)
$iam_client = Aws::IAM::Client.new(
  access_key_id: creds['AWS_ACCESS_KEY_ID'],
  secret_access_key: creds['AWS_SECRET_ACCESS_KEY'],
  region: creds['AWS_DEFAULT_REGION']
)

$project_root = Manager.find_project_root
$project_config = Manager.read_project_config

module Lambdart
  # Your code goes here...
#  autoload :Lambda, 'lambdart/lambda'
#  autoload :S3, 'lambdart/s3'
#  autoload :Manager, 'lambdart/manager'
#  autoload :Iam, 'lambdart/iam'
#  autoload :Sync, 'lambdart/sync'
  
end


