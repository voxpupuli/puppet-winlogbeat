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
# @param conf_template [String] The configuration template to use to generate the main winlogbeat.yml config file
# @param download_url [String] The URL of the zip file that should be downloaded to install winlogbeat
# @param install_dir [String] Where winlogbeat should be installed
# @param outputs [Hash] Will be converted to YAML for the required outputs section of the winlogbeat config
# @param package_verion [String] The version parameter for the winlogbeat package
# @param registry_file [String] The registry file used to store positions, absolute or relative to working directory (default .winlogbeat.yml)
# @param service_enable [String] The enable parameter on the winlogbeat service (default: true)
# @param service_ensure [String] The ensure parameter on the winlogbeat service (default: running)
# @param shipper [Hash] Will be converted to YAML to create the optional shipper section of the winlogbeat config
# @param logging [Hash] Will be converted to YAML to create the optional logging section of the winlogbeat config
# @param tmp_dir [String] Where winlogbeat should be temporarily downloaded to so it can be installed
# @param event_logs [Hash] Event_logs that will be forwarded.
# @param event_logs_merge [Boolean] Whether $event_logs should merge all hiera sources, or use simple automatic parameter lookup

class winlogbeat (
  $conf_template    = $winlogbeat::params::conf_template,
  $config_file      = $winlogbeat::params::config_file,
  $download_url     = $winlogbeat::params::download_url,
  $install_dir      = $winlogbeat::params::install_dir,
  $outputs          = $winlogbeat::params::outputs,
  $package_ensure   = $winlogbeat::params::package_ensure,
  $registry_file    = $winlogbeat::params::registry_file,
  $service_enable   = $winlogbeat::params::service_enable,
  $service_ensure   = $winlogbeat::params::service_ensure,
  $shipper          = $winlogbeat::params::shipper,
  $logging          = $winlogbeat::params::logging,
  $tmp_dir          = $winlogbeat::params::tmp_dir,
  $event_logs       = [],
  $event_logs_merge = false,
) inherits winlogbeat::params {

  $kernel_fail_message = "${::kernel} is not supported by winlogbeat."

  validate_bool($event_logs_merge)

  if $event_logs_merge {
    $event_logs_temp = hiera_array('winlogbeat::event_logs', $event_logs)
  } else {
    $event_logs_temp = $event_logs
  }

  if !empty($event_logs_temp) {
    $event_logs_final = prefix($event_logs_temp, "name: ")
  }

  if $config_file != $winlogbeat::params::config_file {
    warning('You\'ve specified a non-standard config_file location - winlogbeat may fail to start unless you\'re doing something to fix this')
  }

  validate_array($event_logs_final)
  validate_hash($outputs, $logging)
  validate_string($registry_file, $package_ensure)

  anchor { 'winlogbeat::begin': } ->
  class { 'winlogbeat::install': } ->
  class { 'winlogbeat::config': } ->
  class { 'winlogbeat::service': } ->
  anchor { 'winlogbeat::end': }

}
