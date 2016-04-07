require 'thor'
require 'thor/group'

module Lambdart
  module Generators

    class RoleGenerator < Thor::Group
      include Thor::Actions
      desc 'Generate a new lambdart role'

      # Define arguments and options
      argument :role_name
      argument :template_file
      #method_option :template, :aliases => "-t", :desc => "Delete the file after parsing it"
      #class_option :template, :aliases => "-t", :desc => "Specify a custom template file instead of the default", :default => "role.json"

      def create_role_config
        template "#{template_file}", "#{role_name}.json"
      end
    end 
 
  end
end
