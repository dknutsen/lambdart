






module Iam
  VERSION = "2012-10-17"
  PERMISSIONS = ["logging", "s3", "lambda_invoke", "dynamodb"]

    # create/modify role if necessary
  #  role_name = get_remote_function(full_function_name)[:role].split('/')[1]
  #  role = Hash($iam_client.get_role({role_name: role_name}))
  #  #pd = JSON.parse(CGI.unescape(role[:role][:assume_role_policy_document]))
  #  policy_names = Hash($iam_client.list_role_policies({role_name: "city_account_updates"}))[:policy_names]
  #  policy = Hash($iam_client.get_role_policy({role_name: role_name, policy_name: policy_names[0]}))
  #  pd = JSON.parse(CGI.unescape(policy[:policy_document]))






  # TODO local equivalents of the above? Ex:
  #def self.list_local_roles(project_root)
  #  ls("#{project_root}/roles")
  #end
  #def self.local_role_exists(project_root, role_name)
  #  self.list_local_roles(project_root).include? role_name
  #end
  #


  def self.create_remote_role(iam_client, role_name, options={})
    # TODO: allow setting 'path' 
    # TODO: hardcode this somewhere else?!? Maybe in a template in /templates?
    arpd = JSON.pretty_generate({
      "Version"=>"2012-10-17", 
      "Statement"=>[{
        "Effect"=>"Allow", 
        "Principal"=>{
          "Service"=>"lambda.amazonaws.com"
        }, 
        "Action"=>"sts:AssumeRole"
      }]
    })
    iam_client.create_role({role_name: role_name, assume_role_policy_document: arpd})
  end
  
  def self.list_remote_roles(iam_client)
    iam_client.list_roles[:roles].map{|role| role[:role_name]}
  end

  def self.get_remote_role(iam_client, role_name)
    Hash(iam_client.get_role(role_name: role_name))[:role]
  end

  def self.remote_role_exists?(iam_client, role_name)
    self.list_remote_roles(iam_client).include? role_name
  end



  def self.list_remote_role_policies(iam_client, role_name)
    iam_client.list_role_policies(role_name:role_name)[:policy_names]
  end

  def self.get_remote_role_policy(iam_client, role_name, policy_name)
    JSON.parse(CGI.unescape( iam_client.get_role_policy(role_name:role_name, policy_name:policy_name)[:policy_document] ))
  end

  def self.delete_remote_role_policy(iam_client, role_name, policy_name)
    iam_client.delete_role_policy(role_name: role_name, policy_name: policy_name)
  end

  def self.add_remote_role_policy(iam_client, role_name, policy_name, policy_document)
    pdoc = JSON.pretty_generate(policy_document)
    iam_client.put_role_policy(role_name: role_name, policy_name: policy_name, policy_document: pdoc)
  end

  def self.create_role_policy(permissions)
    policy = {
      Version: VERSION,
      Statement: []
    }
    permissions.each do |perm, statements|
      permission = perm.to_s
      unless PERMISSIONS.include? permission
        #TODO: throw error instead?
        puts "Unrecognized permission #{permission}"
        next
      end
      statements.each do |options|
        rps = method("get_iam_rps_#{permission}").call(options)
        policy[:Statement].push(rps)
      end
    end
    return JSON.parse(JSON.pretty_generate(policy))
  end




  #----- IAM role policy statement (RPS) generators -----
  def self.get_iam_rps_logging(options={})
    #TODO: allow 'options' to set finer-grained 'Action' controls
    return {
      "Effect"=> "Allow",
      "Action"=> [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource"=> "arn:aws:logs:*:*:*"
    }
  end

  def self.get_iam_rps_s3(options={})
    bucket_name = options[:bucket] || options["bucket"] || "*"
    actions = options[:actions] || ["s3:GetObject", "s3:PutObject"]
    return {
      "Effect" => "Allow",
      "Action" => actions,
      "Resource"=> [
        "arn:aws:s3:::#{bucket_name}"
      ]
    }
  end

  def self.get_iam_rps_lambda_invoke(options={})
    function_name = options[:function_name] || "*"
    actions = options[:actions] || ["lambda:InvokeAsync", "lambda:InvokeFunction"]
    return {
      "Effect" => "Allow",
      "Action" => actions,
      "Resource": [
        # TODO: fix this
        "arn:aws:lambda:*"
      ]
    }
  end

  def self.get_iam_rps_dynamodb(options={})
    function_name = options[:table_name] || "*"
    actions = options[:actions] || ["dynamodb:GetItem", "dynamodb:Scan"]
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

