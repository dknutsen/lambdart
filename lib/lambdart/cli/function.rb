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
        # read the config file, add the env to it, write it
        config = Manager.read_function_config(function_name, true)
        config['environments'] = [] unless config.include? 'environments'
        config['environments'].push env_name unless config['environments'].include? env_name
        Manager.write_function_config(function_name, config)
        # write .env file in the function src directory
        filename = $project_root + "src" + function_name + "#{env_name}.env"
        File.open(filename, 'w') {|f| f.write("LAMBDART_ENV=#{env_name}") }
      end

      # remove_env

      # set/change_role(function_name, role_name)

      # 
    end
 
 end
end


