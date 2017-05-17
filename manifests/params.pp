# winlogbeat::params
class winlogbeat::params {
  # $package_version = '1.3.1'
  $service_ensure = running
  $service_enable = true
  $outputs        = {}
  $shipper        = {}
  $logging        = {}
  $run_options    = {}

  if versioncmp('1.9.1', $::rubyversion) > 0 {
    $conf_template = "${module_name}/winlogbeat.yml.ruby18.erb"
  } else {
    $conf_template = "${module_name}/winlogbeat.yml.erb"
  }

  case $::kernel {
    'Windows' : {
      # $config_file      = 'C:/Program Files/Winlogbeat/winlogbeat.yml'
      # $download_url     = "https://download.elastic.co/beats/winlogbeat/winlogbeat-${winlogbeat_pkg_version}-windows-x86_64.zip"
      # $install_dir      = 'C:/Program Files'
      $winlogbeat_pkg_name    = 'winlogbeat'
      $winlogbeat_pkg_ensure  = '5.4.0'
      $winlogbeat_pkg_version = $winlogbeat_pkg_ensure
      $winlogbeat_pkg_source  = undef
      $config_file      = "C:/ProgramData/chocolatey/lib/winlogbeat/tools/winlogbeat-${winlogbeat_pkg_version}-windows-x86_64/winlogbeat.yml"
      $registry_file    = "C:/ProgramData/chocolatey/lib/winlogbeat/tools/winlogbeat-${winlogbeat_pkg_version}-windows-x86_64/.winlogbeat.yml"
      $tmp_dir          = 'C:/Windows/Temp'
      $service_provider = undef

    }

    default : {
      fail($winlogbeat::kernel_fail_message)
    }
  }
}
