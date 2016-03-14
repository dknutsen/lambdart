require 'thor'
require 'pathname'
require 'lambdart/manager'

module Lambdart
  module CLI

    class Function < Thor
      desc "add_event_source", "Add an event source to the function config"
      def add_event_source()
        puts "This functionality has not been implemented yet"
      end

      desc "add_env", "Add an environment to the function (config and .env file)"
      def add_env(function_name, env_name)
        puts "This functionality has not been implemented yet"
        # load function config
        # add to environments list (create list if it doesn't exist already)
        # write function config
        # write .env file in the function src directory
        filename = $project_root + "src" + function_name + "#{env_name}.env"
        File.open(local_filename, 'w') {|f| f.write("ENVIRONMENT=\"#{env_name}\"") }
      end
    end
 
 end
end


