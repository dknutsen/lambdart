require 'thor'
require 'thor/group'

module Lambdart
  module Generators

    class FunctionGenerator < Thor::Group
      include Thor::Actions
      desc 'Generate a new lambdart function'

      # this is necessary due to the 'binding' weirdness of the 'template' method
      attr_accessor :name, :runtime, :description, :role_name, :timeout, :memory_size

      # Define arguments and options
      argument :function_name
      argument :runtime
      argument :template_file
      class_option :description, :aliases => "-d", :desc => "Specify a function description", :required => false
      class_option :role, :aliases => "-r", :desc => "Specify a role for the function", :required => false
      class_option :timeout, :desc => "Specify a timeout for the function", :type => :numeric
      class_option :memory, :desc => "Specify a memory size for the function", :type => :numeric

      def create_function_code
        #copy_file "#{runtime}/#{template_file}", "function.#{Manager::RUNTIMES[runtime][:extension]}"
        copy_file "#{template_file}", "function.#{Manager::RUNTIMES[runtime][:extension]}"
      end

      def create_function_config
        # these instance variables will be used in the template
        self.name = function_name
        self.runtime = runtime
        self.description = options[:description] || "This is a lambda function"
        self.role_name = options[:role] || ""
        self.timeout = options[:timeout] || 10
        self.memory_size = options[:memory] || 128

        template "config.json", "config.json"
      end

    end 
 
  end
end






# ----- couldn't get the template command to get the proper binding, why? -----
#      attr_accessor :name, :runtime, :description, :role_name, :timeout, :memory_size
#
#      def create_function_config
# try it with instance variables?
#        self.name = function_name
#        self.runtime = runtime
#        self.description = options[:description] || "This is a lambda function"
#        self.role_name = options[:role] || ""
#        self.timeout = options[:timeout] || 10
#        self.memory_size = options[:memory] || 128
# try it with object variables?
##        @@name = function_name
##        @@runtime = runtime
##        @@description = options[:description] || "This is a lambda function"
##        @@role_name = options[:role] || ""
##        @@timeout = options[:timeout] || 10
##        @@memory_size = options[:memory] || 128
#
#        pp binding.instance_variables.sort
#        pp binding.local_variables.sort
#        pp instance_eval("binding").instance_variables.sort
#        pp instance_eval("binding").local_variables.sort
#
#        template "config.json", "config.json"
#      end
#

