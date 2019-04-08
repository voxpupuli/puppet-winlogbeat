# This class installs the Elastic winlogbeat log shipper and
# helps manage which logs are shipped
#
# @example
# class { 'winlogbeat':
#   outputs => {
#     'logstash' => {
#       'hosts' => [
#         'localhost:5044',
#       ],
#     },
#   },
# }
#
# @param package_ensure [String] The version parameter for the winlogbeat package
# @param service_ensure [String] The ensure parameter on the winlogbeat service (default: running)
# @param service_enable [String] The enable parameter on the winlogbeat service (default: true)
# @param registry_file [String] The registry file used to store positions, absolute or relative to working directory (default .winlogbeat.yml)
# @param outputs [Hash] Will be converted to YAML for the required outputs section of the winlogbeat config
# @param shipper [Hash] Will be converted to YAML to create the optional shipper section of the winlogbeat config
# @param logging [Hash] Will be converted to YAML to create the optional logging section of the winlogbeat config
# @param conf_template [String] The configuration template to use to generate the main winlogbeat.yml config file
# @param download_url [String] The URL of the zip file that should be downloaded to install winlogbeat
# @param install_dir [String] Where winlogbeat should be installed
# @param tmp_dir [String] Where winlogbeat should be temporarily downloaded to so it can be installed
# @param event_logs [Hash] Event_logs that will be forwarded.
# @param event_logs_merge [Boolean] Whether $event_logs should merge all hiera sources, or use simple automatic parameter lookup

class winlogbeat (
  $major_version        = undef,
  $package_ensure       = $winlogbeat::params::package_ensure,
  $service_ensure       = $winlogbeat::params::service_ensure,
  $service_enable       = $winlogbeat::params::service_enable,
  $service_provider     = $winlogbeat::params::service_provider,
  $registry_file        = $winlogbeat::params::registry_file,
  $config_file          = $winlogbeat::params::config_file,
  $outputs              = $winlogbeat::params::outputs,
  $shipper              = $winlogbeat::params::shipper,
  $logging              = $winlogbeat::params::logging,
  $run_options          = $winlogbeat::params::run_options,
  $conf_template        = undef,
  $download_url         = undef,
  $install_dir          = $winlogbeat::params::install_dir,
  $tmp_dir              = $winlogbeat::params::tmp_dir,
  #### v5 only ####
  $use_generic_template = $winlogbeat::params::use_generic_template,
  $beat_name            = $winlogbeat::params::beat_name,
  $tags                 = $winlogbeat::params::tags,
  $queue_size           = $winlogbeat::params::queue_size,
  $max_procs            = $winlogbeat::params::max_procs,
  $fields               = $winlogbeat::params::fields,
  $fields_under_root    = $winlogbeat::params::fields_under_root,
  $metrics              = undef,
  #### End v5 only ####
  $event_logs           = {},
  $event_logs_merge     = false,
  $proxy_address        = undef,
) inherits winlogbeat::params {

  validate_bool($event_logs_merge)

  if $major_version == undef and getvar('::winlogbeat_version') == undef {
    $real_version = '5'
  } elsif $major_version == undef and versioncmp($::winlogbeat_version, '5.0.0') >= 0 {
    $real_version = '5'
  } elsif $major_version == undef and versioncmp($::winlogbeat_version, '5.0.0') < 0 {
    $real_version = '1'
  } else {
    $real_version = $major_version
  }

  if $conf_template != undef {
    $real_conf_template = $conf_template
  } elsif $real_version == '1' {
    if versioncmp('1.9.1', $::rubyversion) > 0 {
      $real_conf_template = "${module_name}/winlogbeat1.yml.ruby18.erb"
    } else {
      $real_conf_template = "${module_name}/winlogbeat1.yml.erb"
    }
  } elsif $real_version == '5' {
    if $use_generic_template {
      $real_conf_template = "${module_name}/winlogbeat1.yml.erb"
    } else {
      $real_conf_template = "${module_name}/winlogbeat5.yml.erb"
    }
  }

  $real_download_url = $download_url ? {
    undef   => "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-${package_ensure}-windows-${winlogbeat::params::url_arch}.zip",
    default => $download_url,
  }

  if $event_logs_merge {
    $event_logs_final = hiera_hash('winlogbeat::event_logs', $event_logs)
  } else {
    $event_logs_final = $event_logs
  }

  if $config_file != $winlogbeat::params::config_file {
    warning('You\'ve specified a non-standard config_file location - winlogbeat may fail to start unless you\'re doing something to fix this')
  }

  validate_hash($outputs, $logging, $event_logs_final)
  validate_string($registry_file, $package_ensure)

  if(!empty($proxy_address)){
    validate_re($proxy_address, ['^(http(?:s)?\:\/\/[a-zA-Z0-9]+(?:(?:\.|\-)[a-zA-Z0-9]+)+(?:\:\d+)?(?:\/[\w\-]+)*(?:\/?|\/\w+\.[a-zA-Z]{2,4}(?:\?[\w]+\=[\w\-]+)?)?(?:\&[\w]+\=[\w\-]+)*)$'], 'ERROR: You must enter a proxy url in a valid format i.e. http://proxy.net:3128')
  }

  anchor { 'winlogbeat::begin': }
  -> class { 'winlogbeat::install': }
  -> class { 'winlogbeat::config': }
  -> class { 'winlogbeat::service': }
  -> anchor { 'winlogbeat::end': }
}
