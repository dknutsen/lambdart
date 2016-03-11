
require 'lambdart/iam'
require 'lambdart/manager'

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
  end
end
