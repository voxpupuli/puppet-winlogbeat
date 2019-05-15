# winlogbeat::config
#
# Manage the configuration of winlogbeat
#
# @summary A private class to manage the winglobeat config file

class winlogbeat::config {
  $major_version = regsubst($winlogbeat::package_ensure, '^(\d)\..*', '\1')

  if versioncmp($major_version, '6') >= 0 {
    $winlogbeat_config_temp = delete_undef_values({
      'shutdown_timeout'  => $winlogbeat::shutdown_timeout,
      'name'              => $winlogbeat::beat_name,
      'tags'              => $winlogbeat::tags,
      'max_procs'         => $winlogbeat::max_procs,
      'fields'            => $winlogbeat::fields,
      'fields_under_root' => $winlogbeat::fields_under_root,
      'winlogbeat'          => {
        'registry_file'     => $winlogbeat::registry_file,
        'shutdown_timeout'  => $winlogbeat::shutdown_timeout,
        'event_logs'        => $winlogbeat::event_logs,
      },
      'output'            => $winlogbeat::outputs,
      'logging'           => $winlogbeat::logging,
      'runoptions'        => $winlogbeat::run_options,
      'processors'        => $winlogbeat::processors,
      'setup'             => $winlogbeat::setup,
      'queue'             => $winlogbeat::queue,
    })
    # Add the 'xpack' section if supported (version >= 6.1.0) and not undef
    if $winlogbeat::xpack and versioncmp($winlogbeat::package_ensure, '6.1.0') >= 0 {
      $winlogbeat_config = deep_merge($winlogbeat_config_temp, {'xpack' => $winlogbeat::xpack})
    }
    else {
      $winlogbeat_config = $winlogbeat_config_temp
    }
  } else {
    $winlogbeat_config = delete_undef_values({
      'shutdown_timeout'  => $winlogbeat::shutdown_timeout,
      'name'              => $winlogbeat::beat_name,
      'tags'              => $winlogbeat::tags,
      'queue_size'        => $winlogbeat::queue_size,
      'max_procs'         => $winlogbeat::max_procs,
      'fields'            => $winlogbeat::fields,
      'fields_under_root' => $winlogbeat::fields_under_root,
      'winlogbeat'          => {
        'spool_size'       => $winlogbeat::spool_size,
        'idle_timeout'     => $winlogbeat::idle_timeout,
        'registry_file'    => $winlogbeat::registry_file,
        'publish_async'    => $winlogbeat::publish_async,
        'shutdown_timeout' => $winlogbeat::shutdown_timeout,
        'event_logs'        => $winlogbeat::event_logs,
      },
      'output'            => $winlogbeat::outputs,
      'logging'           => $winlogbeat::logging,
      'runoptions'        => $winlogbeat::run_options,
      'processors'        => $winlogbeat::processors,
    })
  }

  if ($facts['winlogbeat_version']) {
    $skip_validation = versioncmp($facts['winlogbeat_version'], $major_version) ? {
      -1      => true,
      default => false,
    }
  } else {
    $skip_validation = false
  }

  $cmd_install_dir = regsubst($winlogbeat::install_dir, '/', '\\', 'G')
  $winlogbeat_path = join([$cmd_install_dir, 'winlogbeat', 'winlogbeat.exe'], '\\')

  $validate_cmd = ($winlogbeat::disable_config_test or $skip_validation) ? {
    true    => undef,
    default => "\"${winlogbeat_path}\" -N -configtest -c \"%\"",
  }

  file {'winlogbeat.yml':
    ensure       => $winlogbeat::file_ensure,
    path         => $winlogbeat::config_file,
    content      => template($winlogbeat::conf_template),
    validate_cmd => $validate_cmd,
    notify       => Service['winlogbeat'],
  }

}
