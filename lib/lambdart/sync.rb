
require 'lambdart/iam'
require 'lambdart/manager'
require 'lambdart/lambda'

module Lambdart
  module Sync
    def self.sync_role(role_name)
      puts "  Syncing role #{role_name}"
      role_config = Manager.read_role_config(role_name)
      permissions = role_config['permissions']
      local_role_policy = Iam.create_role_policy(permissions)
      if Iam.remote_role_exists?($iam_client, role_name)
        puts "    remote role exists, checking policy for changes..."
        remote_role_policies = Iam.list_remote_role_policies($iam_client, role_name)
        # TODO: this is really inelegant
        unless remote_role_policies.any?
          policy_name = "#{role_name}_permission_policy"
          Iam.add_remote_role_policy($iam_client, role_name, policy_name, local_role_policy)
          return
        end
        #TODO: safe to assume only one role policy per role? Use name instead?
        policy_name = remote_role_policies[0]
        remote_role_policy = Iam.get_remote_role_policy($iam_client, role_name, policy_name)
        unless local_role_policy == remote_role_policy
          puts "    local and remote role policies are different, updating remote"
          Iam.delete_remote_role_policy($iam_client, role_name, policy_name)
          Iam.add_remote_role_policy($iam_client, role_name, policy_name, local_role_policy)
        else
          puts "    local and remote role policies match, nothing to sync"
        end
      else
        puts "    remote role does not exist, creating it..."
        Iam.create_remote_role($iam_client, role_name)
        # TODO: change this name?!?
        policy_name = "#{role_name}_permission_policy"
        puts "    adding policy #{policy_name} to role #{role_name}"
        Iam.add_remote_role_policy($iam_client, role_name, policy_name, local_role_policy)
      end
      Iam.get_remote_role($iam_client, role_name)[:arn]
    end

    def self.sync_function(function_name, env="", function_config={})
      abort("Function #{function_name} cannot be found in this project. [#{Manager.get_local_functions}]") unless Manager.get_local_functions.include? function_name

      prefix = ""
      function_config = function_config_setup(prefix, function_name, env) unless function_config.any?

      puts "Syncing function #{function_config['full_name']}"

      # sync function's role first TODO: return arn from this?
      abort("ERROR: Function #{function_name} does not have a role specified. Please specify one in the function config.") if function_config['role'].empty?
      abort("ERROR: Specified role \"#{function_config['role']}\" does not exist in the project. Please create it with \"lambdart create role #{function_config['role']}\" or specify a different one in the function config") unless Manager.get_local_roles.include? function_config['role']
      function_config['role_arn'] = sync_role(function_config['role'])

      # build function
      function_config['zip_file'] = Manager.build_function(function_config)

      # TODO: move this whole block into a 'Lambda.create_or_update_function' function? return function arn from it?
      unless Lambda.get_remote_function_names($lambda_client).include? function_config['full_name']
        puts "  Remote function #{function_config['full_name']} does not yet exist, creating..."
        function_config['arn'] = Lambda.create_remote_function($lambda_client, function_config)
      else
        puts "  Remote function #{function_config['full_name']} exists"


        # diff and update local and remote function config
        puts "    updating function config"
        remote_config = Lambda.get_remote_function_config($lambda_client, function_config['full_name'])
        unless Lambda.diff_local_remote_config(function_config, remote_config)
          puts "    local and remote #{function_config['full_name']} configs are different, updating..."
          Lambda.update_remote_function_config($lambda_client, function_config)
        else
          puts "    local and remote configs match"
        end

        # update function code
        puts "    updating function code"
        begin
          function_config['arn'] = Lambda.update_remote_function_code($lambda_client, function_config)
          puts "    function #{function_config['full_name']} code deployed successfully"
        rescue => e
          puts "There was an error updating the function code:\n#{e}"
        end
      end

      sync_event_sources(function_config)
    end

    def self.sync_event_sources(config)
      return unless config.include? 'event_sources' and config['event_sources'].any?

      puts "  Syncing #{config['event_sources'].length} event sources"
      policy = Lambda.get_remote_function_policy($lambda_client, config['full_name'])
      psids = policy.any? ? policy['Statement'].map{|k| k['Sid']} : []

      # loop over event source types from function config (types = "s3", "dynamodb", etc)
      config['event_sources'].each do |type, sources|
        sources = [sources] if sources.is_a? Hash
        # now loop over each source for each source type and sync them
        case type
        when "s3"
          sources.each do |source|
            sid = "#{config['full_name']}_s3_#{source['bucket']}_invoke_statement"
            puts "    syncing S3 event source with sid #{sid}"
            Lambda.add_s3_permission($lambda_client, config['full_name'], sid, source['bucket']) unless psids.include? sid
            psids.push sid
            S3.sync_s3_notification_config($s3_client, config['arn'], source)
          end
        else
          puts "  Warning: Invalud event source type #{type} specified, skipping..."
        end
      end
    end




    def self.function_config_setup(project_prefix, function_name, env)
      function_config = Manager.read_function_config(function_name)
      determine_function_env(env, function_config)
      determine_function_name(project_prefix, function_name, function_config)
      return function_config
    end

    def self.determine_function_name(project_prefix, function_name, function_config)
      # we only add the _<env> suffix to the function name if there is an env and if the
      # 'function_per_env' option is true in the function config
      denv = function_config['deploy_env'] || ""
      env = function_config['function_per_env'] == true ? denv : ""
      function_config['name'] = function_name
      function_config['full_name'] = ([project_prefix, function_name, env] - ["", nil]).join("_")
    end

    def self.determine_function_env(env, function_config)
      if function_config.include? 'environments' and function_config['environments'].any?
        abort "Error: you need to specify an environment to sync out of the following: #{function_config['environments']}" if env.empty?
        abort "Error: function has environments specified but the provided environment (#{env}) is not among them" unless function_config['environments'].include? env
        function_config['deploy_env'] = env
      end
    end

  end
end
