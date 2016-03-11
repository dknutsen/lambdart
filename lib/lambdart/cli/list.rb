require 'thor'
require 'pathname'
require 'lambdart/manager'

module Lambdart
  module CLI

    class List < Thor
      desc "functions", "List all functions that are part of this project"
      def functions()
        puts Manager.get_local_functions
      end

      desc "roles", "List all roles that are part of this project"
      def roles()
        puts Manager.get_local_roles
      end
    
      desc "templates", "List all tempaltes that are part of this project"
      def templates()
        puts "This feature is not yet implemented"
      end
    end
 
 end
end


