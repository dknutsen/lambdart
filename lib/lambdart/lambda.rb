require 'pp'

require_relative 'utils'

module Lambda
  # create some runtime-related mappings and helpers
  # TODO: put these in a json template?!?
  # TODO: PUT THIS SOMEWHERE ELSE
  RUNTIMES = {
    "python" => {
      :name => "python2.7",
      :package_manager => "pip install PACKAGE -t PATH"
    },
    "node" => {
      :name => "nodejs",
      :package_manager => "npm install PACKAGE"
    },
    "java" => {
      :name => "java8",
      :package_manager => "PUTSOMETHINGHERE"
    }
  }



  # TODO: don't love that we have to pass the role ARN in this way, better way?
  def self.create_remote_function(lambda_client, config)
    Utils.validate_config_args(%w[full_name aws_runtime role_arn handler description timeout memory_size zip_file], config)
pp config
    resp = lambda_client.create_function({
      function_name: config['full_name'],
      runtime:       config['aws_runtime'],
      role:          config['role_arn'],
      handler:       config['handler'],
      description:   config['description'],
      timeout:       config['timeout'],
      memory_size:   config['memory_size'],
      code: {
        zip_file: IO.read(config['zip_file']),
      },
    })
    # return function arn
    resp[:function_arn]
  end


  def self.update_remote_function_config(lambda_client, config)
    Utils.validate_config_args(%w[full_name role_arn handler description timeout memory_size], config)
   
    resp = lambda_client.update_function_configuration({
      function_name: config['full_name'],
      role:          config['role_arn'],
      handler:       config['handler'],
      description:   config['description'],
      timeout:       config['timeout'],
      memory_size:   config['memory_size'],
    })
    #puts JSON.pretty_generate(Hash(resp))
    # TODO: return status code or something?
  end


  def self.update_remote_function_code(lambda_client, config)
    Utils.validate_config_args(%w[full_name zip_file], config)

    resp = lambda_client.update_function_code({
      function_name: config['full_name'],
      zip_file: IO.read(config['zip_file']),
    })
    # return function arn
    resp[:function_arn]
  end


  def self.get_remote_function_names(lambda_client)
    # TODO: make it get only functions for this project? (by prefix)
    lambda_client.list_functions[:functions].map{|func| func[:function_name]}
  end

  def self.get_remote_function(lambda_client, function_name)
    # TODO: use config instead of function_name?
    return Hash(lambda_client.get_function :function_name=>function_name)
  end

  def self.get_remote_function_config(lambda_client, function_name)
    # TODO: use config instead of function_name?
    return Hash(lambda_client.get_function_configuration :function_name=>function_name)
  end

  def self.get_remote_function_policy(lambda_client, function_name)
    # TODO: use config instead of function_name?
    begin
      policy = JSON.parse(Hash(lambda_client.get_policy({function_name:function_name}))[:policy])
    rescue Aws::Lambda::Errors::ResourceNotFoundException
      policy = {}
    end
    return policy
  end

  def self.diff_local_remote_config(local, remote)
    return false unless local['role'] == remote[:role].split('/')[1]
    return false unless local['handler'] == remote[:handler]
    return false unless local['description'] == remote[:description]
    return false unless local['timeout'] == remote[:timeout]
    return false unless local['memory_size'] == remote[:memory_size]
    return true # they are the same
  end




  #------- function permissions ---------
  # these will match up one to one with event sources(?)
#  def add_permission(lambda_client, sid, source_config)
#    # validate source config first?
#    case source_config
#    when "s3"
#
#    end
#  end 

  def self.add_s3_permission(lambda_client, function_name, sid, bucket_name)
    # TODO: change args to config?
    # TODO: generate the sid here or in another function?
    #sid = "#{full_function_name}_s3_#{bucket_name}_invoke_statement"
    lambda_client.add_permission({
      function_name: function_name,
      statement_id:  sid,
      action:        "lambda:InvokeFunction",
      principal:     "s3.amazonaws.com",
      source_arn:    "arn:aws:s3:::#{bucket_name}"
    })
  end

  def self.add_dynamodb_permission(lambda_client, function_name, sid, table_name)
    # TODO: change args to config?
    # TODO: generate the sid here or in another function?
    #sid = "#{full_function_name}_dynamodb_#{table_name}_invoke_statement"
    raise NotImplementedError
    lambda_client.add_permission({
      function_name: full_function_name,
      statement_id:  sid,
      action:        "lambda:InvokeFunction",
      principal:     "dynamodb.amazonaws.com",
      source_arn:    "arn:aws:"
    })
  end





end














