require 'thor'
require 'pathname'
require 'lambdart/manager'

module Lambdart
  module CLI

    class Role < Thor
      desc "add_permission [S3|LambdaInvoke|Logging]", "Add a permission to this role"
      def add_permission()
        puts "This functionality has not been implemented yet"
      end

    end
 
 end
end


