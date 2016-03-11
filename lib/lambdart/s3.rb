require 'pp'

module S3

  def self.sync_s3_notification_config(s3_client, function_arn, event_source)
    # TODO: any event_source validation?
    old = S3.get_bucket_notification_config(s3_client, event_source['bucket'])
    new = S3.assemble_bucket_notification_config(s3_client, function_arn, event_source)
    if old != new
      puts "    local and remote event sources do not match, updating remote"
      resp = s3_client.put_bucket_notification_configuration({
        bucket: event_source['bucket'],
        notification_configuration: new
      })
    end
  end


  def self.get_bucket_notification_config(s3_client, bucket_name)
    Hash(s3_client.get_bucket_notification_configuration({bucket: bucket_name}))
  end


  def self.assemble_bucket_notification_config(s3_client, function_arn, event_source)
    function_name = function_arn.split(":").last
    bnc = get_bucket_notification_config(s3_client, event_source['bucket'])
    bnc[:lambda_function_configurations] = [] unless bnc.include? :lambda_function_configurations
    # construct id for this notification source
    ncid = "#{event_source['bucket']}_notify_lambda_#{function_name}"
    existing = bnc[:lambda_function_configurations].select {|config| config[:id] == ncid}
    if existing.any?
      update_lambda_notification_config(existing[0], event_source)
    else
      bnc[:lambda_function_configurations].push generate_lambda_notification_config(ncid, function_arn, event_source)
    end
    return bnc 
  end


  def self.update_lambda_notification_config(config, event_source)
    config[:events] = event_source['events'] if event_source.include? 'events'
    if event_source.include? 'prefix'
      config[:filter][:key][:filter_rules].reject!{|fr| fr[:name]=="Prefix"} 
      config[:filter][:key][:filter_rules].push({name: "Prefix", value: event_source['prefix']})
    end
    if event_source.include? 'suffix'
      config[:filter][:key][:filter_rules].reject!{|fr| fr[:name]=="Suffix"} 
      config[:filter][:key][:filter_rules].push({name: "Suffix", value: event_source['suffix']})
    end
  end


  # args only
  def self.generate_lambda_notification_config(id, function_arn, event_source)
    # TODO: make this into a template instead of hard-coding it
    config = {
      id: id,
      lambda_function_arn: function_arn,
      events: event_source['events'],
      filter: {
        key: {
          filter_rules: [],
        },
      },
    }
    config[:filter][:key][:filter_rules].push({name: "Prefix", value: event_source['prefix']}) if event_source.include? 'prefix'
    config[:filter][:key][:filter_rules].push({name: "Suffix", value: event_source['suffix']}) if event_source.include? 'suffix'
    return config
  end

end

