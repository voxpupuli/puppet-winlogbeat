# winlogbeat::service
#
# Manage the winlogbeat service
#
# @summary A private class to manage the winlogbeat service
class winlogbeat::service {
  service { 'winlogbeat':
    ensure   => $winlogbeat::service_ensure,
    enable   => $winlogbeat::service_enable,
    provider => $winlogbeat::service_provider,
  }
}