


module Utils
  def self.validate_config_args(requirements, config)
    raise ArgumentError, "Config containing keys [#{config.keys}] is missing one or more of required arguments: #{requirements}" unless requirements.all? {|s| config.key? s}
  end
end


