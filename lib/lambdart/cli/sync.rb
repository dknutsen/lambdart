require 'thor'
require 'pathname'

module Lambdart
  module CLI
    class Sync < Thor
      desc "all", "Sync all functions and roles in the project"
      def all()
        puts "This feature is not yet implemented"
      end

      desc "role <role name>", "Sync the specified role"
      def role(role_name)
        puts "This feature is not yet implemented"
      end

      desc "function <function_name> [env]", "Sync the specified function"
      def function(function_name, env="")
        puts "This feature is not yet implemented"
      end
    end
  end
end




