require 'thor'
require 'thor/group'

module Lambdart
  module Template

    class ProjectGenerator < Thor::Group
      include Thor::Actions
      desc 'Generate a new lambdart project'

      # Define arguments and options
      argument :project_name

      def self.source_root
        File.join(File.dirname(__FILE__), "..", "..", "..", "templates", "project")
      end

      def create_project_dirs
        empty_directory 'src'
        empty_directory 'roles'
      end
  
      def create_project_config
        template 'project.lambdart', "#{project_name}.lambdart"
      end

      def create_git_file
        copy_file 'gitignore', '.gitignore'
      end

      def create_secrets_file
        copy_file 'secrets.yml', 'secrets.yml'
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
