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
# @param conf_template [String] The configuration template to use to generate the main filebeat.yml config file
# @param download_url [String] The URL of the zip file that should be downloaded to install winlogbeat
# @param install_dir [String] Where winlogbeat should be installed
# @param outputs [Hash] Will be converted to YAML for the required outputs section of the winlogbeat config
# @param shipper [Hash] Will be converted to YAML to create the optional shipper section of the winlogbeat config
# @param logging [Hash] Will be converted to YAML to create the optional logging section of the winlogbeat config
# @param tmp_dir [String] Where winlogbeat should be temporarily downloaded to so it can be installed
# @param event_logs [Hash] Event_logs that will be forwarded.
# @param event_logs_merge [Boolean] Whether $event_logs should merge all hiera sources, or use simple automatic parameter lookup

class winlogbeat {
  $download_url     = $winlogbeat::params::download_url,
  $install_dir      = $winlogbeat::params::install_dir,
  $outputs          = $winlogbeat::params::outputs,
  $shipper          = $winlogbeat::params::shipper,
  $logging          = $winlogbeat::params::logging,
  $tmp_dir          = $winlogbeat::params::tmp_dir,
  $event_logs       = {},
  $event_logs_merge = false,
) inherits filebeat::params {

  validate_bool($event_logs_merge)


  if $event_logs_merge {
    $event_logs_final = hiera_hash('winlogbeat::event_logs', $event_logs)
  } else {
    $event_logs_final = $event_logs
  }

  validate_hash($outputs, $logging)
}