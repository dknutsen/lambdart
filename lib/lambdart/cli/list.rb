require 'thor'
require 'pathname'
require 'lambdart/manager'

module Lambdart
  module CLI

    class List < Thor
      desc "functions", "List all functions that are part of this project"
      def functions()
        begin
          puts (Manager.find_project_root+"src").children.select{|file| file.directory?}.map(&:basename)
        rescue => e
          puts "Could not find a *.lambdart project file, are you somewhere in a lambdart project?"
        end
      end

      desc "roles", "List all roles that are part of this project"
      def roles()
        begin
          puts (Manager.find_project_root+"roles").children.select{|file| file.file? and file.extname == ".json"}.map(&:basename)
        rescue => e
          puts "Could not find a *.lambdart project file, are you somewhere in a lambdart project?"
        end
      end
    
      desc "templates", "List all tempaltes that are part of this project"
      def templates()
        puts "This feature is not yet implemented"
      end
    end
 
 end
end


