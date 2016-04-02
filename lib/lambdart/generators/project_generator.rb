require 'thor'
require 'thor/group'

module Lambdart
  module Generators

    class ProjectGenerator < Thor::Group
      include Thor::Actions
      desc 'Generate a new lambdart project'

      # Define arguments and options
      argument :project_name

#      def self.source_root
#        File.join(File.dirname(__FILE__), "..", "..", "..", "templates", "project")
#      end

      def create_project_dirs
        empty_directory 'src'
        empty_directory 'roles'
        empty_directory 'templates'
        empty_directory File.join('templates', 'roles')
        empty_directory File.join('templates', 'envs')
        empty_directory File.join('templates', 'functions')
        empty_directory File.join('templates', 'functions', 'node')
        empty_directory File.join('templates', 'functions', 'python')
        empty_directory File.join('templates', 'functions', 'java')
      end
  
      def create_project_config
        template 'project.lambdart', "#{project_name}.lambdart"
      end

      def create_git_files
        copy_file 'gitignore', '.gitignore'
      end

      def create_secrets_file
        copy_file 'secrets.yml', 'secrets.yml'
      end

      def init_git_repo
        puts %x(cd #{self.destination_root}; git init)
      end

#      def create_lib_file
#        create_file "#{name}/lib/#{name}.rb" do
#          "class #{name.camelize}\nend"
#        end
#      end

#      def create_test_file
#        test = options[:test_framework] == "rspec" ? :spec : :test
#        create_file "#{name}/#{test}/#{name}_#{test}.rb"
#      end
    end 
 
  end
end
