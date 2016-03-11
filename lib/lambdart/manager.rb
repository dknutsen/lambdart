require 'pathname'
require 'json'
require 'Open3'

require 'lambdart/utils'

module Manager

  # create some runtime-related mappings and helpers
  # TODO: put these in a json template?!?
  RUNTIMES = {
    "python" => {
      :name => "python2.7",
      :package_manager => "pip install PACKAGE -t PATH"
    },
    "node" => {
      :name => "nodejs",
      :package_manager => "npm install PACKAGE"
    },
    "java" => {
      :name => "java8",
      :package_manager => "PUTSOMETHINGHERE"
    }
  }
  REVERSE_RUNTIMES = {
    "python2.7" => "python", 
    "nodejs" => "node", 
    "java8" => "java"
  }
  EVENT_SOURCES = %w[s3 dynamodb]

  # filetypes that will be copied from the function source to the build directory
  # TODO: move this into the project config file so users can change it
  #$build_file_types = ["js", "java", "py", 'env']
  BUILD_FILETYPES = %w[js java py]

  def self.find_project_root
    find_project_config.dirname
  end

  def self.find_project_config
    path = Pathname.pwd
    path.ascend do |dir|
      project_config = dir.children.select { |c| c.file? and c.extname.to_s == ".lambdart" }
      return project_config.first if project_config.any?
    end
    abort("Could not find a *.lambdart project file, are you somewhere in a lambdart project?")
  end

  def self.read_project_config
    JSON.parse(find_project_config.read)
  end

  def self.read_function_config(function_name)
    # TODO: change 'fails' to raise exceptions instead 
    function_config = {}
    begin
      function_conf = JSON.parse(File.read(($project_root+"src"+"#{function_name}"+"config.json").to_s))
    rescue => e
      fail "The function config file contains a syntax error:\n#{e}"
    else
      function_config = function_conf
    end

    # Validation
    fail "Function #{function_name} config 'runtime' value is invalid" unless RUNTIMES.include? function_config['runtime']
    fail "Invalid event source type" unless function_config['event_sources'].all?{|type,source| EVENT_SOURCES.include? type}

    # Do some extra processing
    function_config['aws_runtime'] = RUNTIMES[function_config['runtime']][:name]  #TODO: should we do this here?!?

    return function_config
  end

  # reads and validates a role configuration file
  def self.read_role_config(role_name)
    # TODO: change 'fails' to raise exceptions instead 
    role_config = {}
    begin
      role_conf = JSON.parse(File.read(($project_root+"roles"+"#{role_name}.json").to_s)) 
    rescue => e
      fail "The role config file #{role_name}.json contains a syntax error or does not exist:\n#{e}"
    else
      role_config = role_conf
    end

    # TODO: add some validation logic here
    #fail "Function #{function_name} config 'runtime' value is invalid" unless RUNTIMES.include? function_config['runtime']  

    return role_config
  end


  def self.get_local_functions()
    (Manager.find_project_root+"src").children.select{|file| file.directory?}.map(&:basename).map(&:to_s)
  end

  def self.get_local_roles()
    (Manager.find_project_root+"roles").children.select{|file| file.file? and file.extname == ".json"}.map(&:basename).map(&:to_s)
  end

  # given a function config and the function build path, installs all dependencies
  def self.install_function_dependencies(build_path, config)
    runtime = config['runtime']
    if config['dependencies'].kind_of?(Array)
      config['dependencies'].each do |dep|
        puts "    installing dependency #{dep}"
        command = RUNTIMES[runtime][:package_manager].sub('PACKAGE', dep).sub('PATH', "#{build_path}/")
        system "#{command} > /dev/null"
      end
    end
  end


  # given a file path, creates the leaf directory and any parents that don't exist
  def self.create_project_directory(directories)
    args = directories.is_a?(String) ? directories.split(File::SEPARATOR) : directories
    build_path = File.join($project_root, directories)
    unless File.directory?(build_path)
      puts("  Creating directory: #{build_path}")
      FileUtils::mkdir_p build_path
    end
  end


  # creates a function build directory and copies function src into it
  def self.copy_function_src_to_build(config)
    Utils.validate_config_args(%w[name full_name], config)

    function_src = File.join($project_root, "src", config['name'])
    function_build_path = File.join($project_root, "build", config['full_name'])

    #TODO: do we need to delete and then recreate? better method?
    ignore, error = Open3.capture2 "rm -rf #{function_build_path}"
    create_project_directory(['build', config['full_name']]) unless File.directory?(function_build_path)

    # copy function source files
    # TODO: make this more failproof, maybe loop
    puts('  Copying function source into build directory')
    ignore1,ignore2,ignore3 = Open3.capture3 "cp #{function_src}/*.{#{BUILD_FILETYPES.join(",")}} #{function_build_path}/"

    # copy the appropriate env file (if this function has environments defined)
    if config.include? 'deploy_env'
      puts("  Copying #{config['deploy_env']} env file into build directory")
      if File.file?("#{function_src}/#{config['deploy_env']}.env")
        ignore1,ignore2,ignore3 = Open3.capture3 "cp #{function_src}/#{config['deploy_env']}.env #{function_build_path}/.env"
      else
        puts "    Warning: #{config['deploy_env']}.env not found in #{function_src}"
      end
    end

    return function_build_path
  end


  def self.create_function_zip(config)
    Utils.validate_config_args(%w[full_name], config)

    # TODO: use different zip method? Like ruby class?
    zip_path = "#{$project_root}/dist/#{config['full_name']}.zip"
    system "cd #{$project_root}/build/#{config['full_name']}; zip -r #{zip_path} .  > /dev/null"
    return zip_path
  end


  # make this into a public command?
  def self.build_function(config)
    Utils.validate_config_args(%w[name full_name], config)

    build_path = copy_function_src_to_build(config)
    install_function_dependencies(build_path, config)
    create_project_directory("dist")
    return create_function_zip(config)
  end


end

