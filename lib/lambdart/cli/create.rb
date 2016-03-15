require 'thor'
require 'pathname'
require 'lambdart/manager'

module Lambdart
  module CLI
    class Create < Thor

      desc "function <function name> <node|python|java> [options]", "Create a new function"
      option :template, :aliases => "-t", :desc => "Specify a custom template file instead of the default"
      def function(function_name, runtime)
        abort("Function #{function_name} already exists!") if Manager.get_local_functions.include? function_name
        abort("Specified runtime #{runtime} is not supported, options are #{Manager::RUNTIMES.keys.to_s}") unless Manager::RUNTIMES.include? runtime

        extension = Manager::RUNTIMES[runtime][:extension]
        template = options.include?(:template) ? "#{options[:template]}.#{extension}" : "function.#{extension}"
        if options.include? template
          abort("Function template #{template} not found in templates/functions/#{runtime}/") unless Manager.get_local_function_templates[runtime].include? template
          source_root = (Manager.find_project_root + 'templates' + 'functios' + runtime).to_s
        else
          source_root = File.join(File.dirname(__FILE__), "..", "..", "..", "templates", "functions", runtime)
        end

        # set the source root which we determined above
        Lambdart::Generators::FunctionGenerator.source_root(source_root)
        # create and invoke the role generator
        # TODO: pass the template as option instead of arg?
        generator = Lambdart::Generators::FunctionGenerator.new([function_name, runtime, template]) 
        generator.destination_root = (Manager.find_project_root + 'src' + function_name).to_s
        generator.invoke_all
      end


      desc "role <role_name> [options]", "Create a new role"
      option :template, :aliases => "-t", :desc => "Specify a custom template file instead of the default"
      def roles(role_name)
        abort("Role #{role_name} already exists!") if Manager.get_local_roles.include? role_name
        template = options[:template] || "role.json"
        if options.include? template
          abort("Role #{role_name} not found in templates/roles/") unless Manager.get_local_role_templates.include? template
          source_root = (Manager.find_project_root + 'templates' + 'roles').to_s
        else
          source_root = File.join(File.dirname(__FILE__), "..", "..", "..", "templates", "roles")
        end
        # set the source root which we determined above
        Lambdart::Generators::RoleGenerator.source_root(source_root)
        # create and invoke the role generator
        # TODO: pass the template as option instead of arg?
        generator = Lambdart::Generators::RoleGenerator.new([role_name, template]) 
        generator.destination_root = (Manager.find_project_root + 'roles').to_s
        generator.invoke_all
      end
   
 
      desc "template", "Create a new template"
      def template()
        puts "This feature is not yet implemented"
      end

    end
 end
end


