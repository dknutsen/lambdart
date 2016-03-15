require 'thor'
require 'thor/group'

module Lambdart
  module Generators

    class FunctionGenerator < Thor::Group
      include Thor::Actions
      desc 'Generate a new lambdart function'

      # Define arguments and options
      argument :function_name
      argument :runtime
      argument :template
      #class_option :template, :aliases => "-t", :desc => "Specify a custom template file instead of the default"

      def create_function_code
        copy_file "#{template}", "function.#{Manager::RUNTIMES[runtime][:extension]}"
      end

#      def create_project_config
#        template "#{template}", "#{role_name}.json"
#      end
    end 
 
  end
end
