# winlogbeat::service
#
# Manage the winlogbeat service
#
# @summary A private class to manage the winlogbeat service
class winlogbeat::service {
  service { 'winlogbeat':
    ensure   => $winlogbeat::real_service_ensure,
    enable   => $winlogbeat::real_service_enable,
    provider => $winlogbeat::service_provider,
  }
}
