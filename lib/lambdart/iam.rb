




require 'pp'

module Iam
  VERSION = "2012-10-17"
  PERMISSIONS = {
    "logging" => [
      "logs:CreateLogGroup", 
      "logs:CreateLogStream", 
      "logs:PutLogEvents"], 
    "s3" => [
      "s3:GetObject", 
      "s3:PutObject"], 
    "lambda_invoke" => [
      "lambda:InvokeAsync", 
      "lambda:InvokeFunction"],
    "dynamodb" => [
      "dynamodb:GetRecords", 
      "dynamodb:GetShardIterator", 
      "dynamodb:DescribeStream", 
      "dynamodb:ListStreams", 
      "logs:CreateLogGroup", 
      "logs:CreateLogStream", 
      "logs:PutLogEvents"]
  }
  # TODO: hardcode this in a template in /templates instead? Overridable?
  TRUST_POLICY = {
    "Version"=>"2012-10-17", 
    "Statement"=>[{
      "Effect"=>"Allow", 
      "Principal"=>{
        "Service"=>"lambda.amazonaws.com"
      }, 
      "Action"=>"sts:AssumeRole"
    }]
  }


  # an IAM role has two parts: 
  # * Trust policy: defines what can assume the role (in this case Lambda)
  # * Access policy: defines what the role allows the assuming function to do
  # First we create the role with the trust policy, then add the access policy
  # to it (The aws-sdk calls it a 'role_policy')




    # create/modify role if necessary
  #  role_name = get_remote_function(full_function_name)[:role].split('/')[1]
  #  role = Hash($iam_client.get_role({role_name: role_name}))
  #  #pd = JSON.parse(CGI.unescape(role[:role][:assume_role_policy_document]))
  #  policy_names = Hash($iam_client.list_role_policies({role_name: "city_account_updates"}))[:policy_names]
  #  policy = Hash($iam_client.get_role_policy({role_name: role_name, policy_name: policy_names[0]}))
  #  pd = JSON.parse(CGI.unescape(policy[:policy_document]))



  # creates a basic role using the iam client and a Lambda trust policy
  def self.create_remote_role(iam_client, role_name, options={})
    # TODO: allow setting 'path' 

    # this is the role trust policy
    arpd = JSON.pretty_generate(TRUST_POLICY)
    iam_client.create_role({role_name: role_name, assume_role_policy_document: arpd})
  end

  # fetches list of remote role names  
  def self.list_remote_roles(iam_client)
    iam_client.list_roles[:roles].map{|role| role[:role_name]}
  end

  # fetches a remote role with a specific name
  def self.get_remote_role(iam_client, role_name)
    Hash(iam_client.get_role(role_name: role_name))[:role]
  end

  # checks whether or not a role exists remotely
  def self.remote_role_exists?(iam_client, role_name)
    self.list_remote_roles(iam_client).include? role_name
  end



  # lists the access policy names for a remote role
  def self.list_remote_role_policies(iam_client, role_name)
    iam_client.list_role_policies(role_name:role_name)[:policy_names]
  end

  # gets the specified access policy for a remote role by name
  def self.get_remote_role_policy(iam_client, role_name, policy_name)
    JSON.parse(CGI.unescape( iam_client.get_role_policy(role_name:role_name, policy_name:policy_name)[:policy_document] ))
  end

  # removes an access policy (by name) from a remote role
  def self.delete_remote_role_policy(iam_client, role_name, policy_name)
    iam_client.delete_role_policy(role_name: role_name, policy_name: policy_name)
  end

  # adds an access policy to a remote role
  def self.add_remote_role_policy(iam_client, role_name, policy_name, policy_document)
    pdoc = JSON.pretty_generate(policy_document)
    iam_client.put_role_policy(role_name: role_name, policy_name: policy_name, policy_document: pdoc)
  end

  # this creates a role access policy
  def self.create_role_policy(permissions)
    policy = {
      Version: VERSION,
      Statement: []
    }
    permissions.each do |perm, perm_statements|
      permission = perm.to_s
      unless PERMISSIONS.keys.include? permission
        #TODO: throw error instead?
        puts "Unrecognized permission #{permission}"
        next
      end
      statements = case perm_statements
      when Array
        perm_statements
      when Hash
        [perm_statements]
      else
        [{}] 
      end 
      statements.each do |options|
        rps = method("get_iam_rps_#{permission}").call(options)
        policy[:Statement].push(rps)
      end
    end
    return JSON.parse(JSON.pretty_generate(policy))
  end




  #----- IAM role policy statement (RPS) generators -----
  # partial access policy which gives the role permission to use logging operations
  def self.get_iam_rps_logging(options={})
    actions = options["actions"] || PERMISSIONS['logging']
    abort("Error: The 'action' specification in the role logging permission is invalid or empty, please either remove it (all permissions) or fix it") unless actions.any?
    #TODO: allow 'options' to set finer-grained 'Action' controls
    return {
      "Effect"=> "Allow",
      "Action"=> actions,
      "Resource"=> "arn:aws:logs:*:*:*"
    }
  end

  # partial access policy which gives the role permission to access S3 resources
  def self.get_iam_rps_s3(options={})
    bucket_name = options["bucket"] || options["bucket"] || "*"
    actions = options["actions"] || PERMISSIONS['s3']
    abort("Error: The 'action' specification in the role s3 permission is invalid or empty, please either remove it (all permissions) or fix it") unless actions.any?
    return {
      "Effect" => "Allow",
      "Action" => actions,
      "Resource"=> [
        "arn:aws:s3:::#{bucket_name}"
      ]
    }
  end

  # partial access policy which gives the role permission to invoke other lambda functions
  def self.get_iam_rps_lambda_invoke(options={})
    function_name = options["function_name"] || "*"
    actions = options["actions"] || PERMISSIONS['lambda_invoke']
    abort("Error: The 'action' specification in the role lambda_invoke permission is invalid or empty, please either remove it (all permissions) or fix it") unless actions.any?
    return {
      "Effect" => "Allow",
      "Action" => actions,
      "Resource": [
        # FIXME: this probably should be more specific and secure
        "arn:aws:lambda:*"
      ]
    }
  end

  # partial access policy which gives the role permission to access dynamodb resources
  def self.get_iam_rps_dynamodb(options={})
    table_name = options["table_name"] || "*"
    actions = options["actions"] || PERMISSIONS['dynamodb']
    abort("Error: The 'action' specification in the role dynamodb permission is invalid or empty, please either remove it (all permissions) or fix it") unless actions.any?
    return {
      "Effect": "Allow",
      "Action": actions,
      "Resource": [
        "arn:aws:dynamodb:*:*:table/#{table_name}"
      ]
    }
#        {
#            "Action": [
#                "dynamodb:GetItem"
#            ],
#            "Effect": "Allow",
#            "Resource": "arn:aws:dynamodb:us-east-1:*:table/eikonUserMapping"
#        },{
#            "Action": [
#                "dynamodb:Scan"
#            ],
#            "Effect": "Allow",
#            "Resource": "arn:aws:dynamodb:us-east-1:*:table/eikon_saml_config"
#        }
    return {}
  end

end

