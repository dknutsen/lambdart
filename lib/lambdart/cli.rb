require 'thor'
require 'pathname'
require 'yaml'

require 'lambdart/cli/list'
require 'lambdart/cli/sync'
require 'lambdart/cli/create'
require 'lambdart/cli/function'
require 'lambdart/cli/role'


# these commands require a created and configured project
$project_commands = %w(list sync create function role)

module Lambdart

  class LambdartCLI < Thor
    def initialize(*args)
      super
      # FIXME: probably a better way of doing this
      # unless we're initializing a new project find our project root, load our secrets files, and create AWS clients
      if $project_commands.include? args[2][:current_command].name
        root = Manager.find_project_root
        creds = YAML.load(File.read((root+'secrets.yml')).to_s)
        $lambda_client = Aws::Lambda::Client.new(
          access_key_id: creds['AWS_ACCESS_KEY_ID'],
          secret_access_key: creds['AWS_SECRET_ACCESS_KEY'],
          region: creds['AWS_DEFAULT_REGION']
        )
        $s3_client = Aws::S3::Client.new(
          access_key_id: creds['AWS_ACCESS_KEY_ID'],
          secret_access_key: creds['AWS_SECRET_ACCESS_KEY'],
          region: creds['AWS_DEFAULT_REGION']
        )
        $iam_client = Aws::IAM::Client.new(
          access_key_id: creds['AWS_ACCESS_KEY_ID'],
          secret_access_key: creds['AWS_SECRET_ACCESS_KEY'],
          region: creds['AWS_DEFAULT_REGION']
        )
        $project_root = Manager.find_project_root
        $project_config = Manager.read_project_config
      end
    end


    desc "init <project name>", "creates a new lambdart project in specified project directory"
    def init(project_name)
      
    end

    desc "list SUBCOMMAND ...ARGS", "list functions, roles, templates, etc"
    subcommand "list", Lambdart::CLI::List

    desc "sync SUBCOMMAND ...ARGS", "sync functions, roles, etc"
    subcommand "sync", Lambdart::CLI::Sync

    desc "create SUBCOMMAND ...ARGS", "create functions, roles, etc"
    subcommand "create", Lambdart::CLI::Create

    desc "function SUBCOMMAND ...ARGS", "perform function tasks, etc."
    subcommand "function", Lambdart::CLI::Function

    desc "role SUBCOMMAND ...ARGS", "perform role tasks, etc."
    subcommand "role", Lambdart::CLI::Role
  end

end

#  option :from, :required => true
#  option :yell, :type => :boolean
#  desc "hello NAME", "say hello to NAME"
#  def hello(name)
#    output = []
#    output << "from: #{options[:from]}" if options[:from]
#    output << "Hello #{name}"
#    output = output.join("\n")
#    puts options[:yell] ? output.upcase : output
#  end

#  desc "hello NAME", "say hello to NAME"
#  options :from => :required, :yell => :boolean
#  def hello(name)
#    output = []
#    output << "from: #{options[:from]}" if options[:from]
#    output << "Hello #{name}"
#    output = output.join("\n")
#    puts options[:yell] ? output.upcase : output
#  end

# :desc: A description for the option. When printing out full usage for a command using cli help hello, this description will appear next to the option.
# :banner: The short description of the option, printed out in the usage description. By default, this is the upcase version of the flag (from=FROM).
# :required: Indicates that an option is required
# :default: The default value of this option if it is not provided. An option cannot be both :required and have a :default.
# :type: :string, :hash, :array, :numeric, or :boolean
# :aliases: A list of aliases for this option. Typically, you would use aliases to provide short versions of the option.


#module GitCLI
#  class Remote < Thor
#    desc "add <name> <url>", "Adds a remote named <name> for the repository at <url>"
#    option :t, :banner => "<branch>"
#    option :m, :banner => "<master>"
#    options :f => :boolean, :tags => :boolean, :mirror => :string
#    def add(name, url)
#      # implement git remote add
#    end
# 
#    desc "rename <old> <new>", "Rename the remote named <old> to <new>"
#    def rename(old, new)
#    end
#  end
# 
#  class Git < Thor
#    desc "fetch <repository> [<refspec>...]", "Download objects and refs from another repository"
#    options :all => :boolean, :multiple => :boolean
#    option :append, :type => :boolean, :aliases => :a
#    def fetch(respository, *refspec)
#      # implement git fetch here
#    end
# 
#    desc "remote SUBCOMMAND ...ARGS", "manage set of tracked repositories"
#    subcommand "remote", Remote
#  end
#end

