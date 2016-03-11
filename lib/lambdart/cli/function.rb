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
      def add_env()
        puts "This functionality has not been implemented yet"
      end
    end
 
 end
end


