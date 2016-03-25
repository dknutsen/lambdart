require 'thor'
require 'pathname'
require 'lambdart/manager'

module Lambdart
  module CLI

    class Validate < Thor
      desc "function", "Validate the function, funciton config, and env files"
      def function(function_name)
        # check if function exists
        # read function config (validates the config)
        # make sure the function handler is legit (look at source and make sure that function exists)
        # make sure the function role exists and is valid
        # make sure function environments have associated .env files and have valid formats
        # issue warnings or errors if anything is wrong
      end

      desc "role", "Validate the fole"
      def role(role_name)
        # check if role exists
        # read role config (this partially validates)
        # make sure what's in each permission key makes sense?
        # issue warnings or errors if anything is wrong, otherwise say it's all good
      end

      desc "project", "Validate all functions and roles in the project"
      def project(role_name)
        # get local functions
        # invoke validate function for each local function
        # get local roles
        # invoke validate role for each local role
      end

    end
 end
end


