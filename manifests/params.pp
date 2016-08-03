class winlogbeat::params {
  $package_version = '1.2.3'
  $service_ensure = running
  $service_enable = true
  $registry_file  = '.winlogbeat.yml'
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
      $config_file      = 'C:/Program Files/winlogbeat/winlogbeat.yml'
      $download_url     = "https://download.elastic.co/beats/winlogbeat/winlogbeat-${package_version}-windows.zip"
      $install_dir      = 'C:/Program Files'
      $tmp_dir          = 'C:/Windows/Temp'
      $service_provider = undef
    }

    default : {
      fail($winlogbeat::kernel_fail_message)
    }
  }
}