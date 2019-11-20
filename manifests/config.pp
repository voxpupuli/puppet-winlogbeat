class winlogbeat::config {
  $winlogbeat_config = delete_undef_values({
    'beat_name'         => $winlogbeat::beat_name,
    'tags'              => $winlogbeat::tags,
    'queue_size'        => $winlogbeat::queue_size,
    'max_procs'         => $winlogbeat::max_procs,
    'fields'            => $winlogbeat::fields,
    'fields_under_root' => $winlogbeat::fields_under_root,
    'winlogbeat'        => {
      'registry_file' => $winlogbeat::registry_file,
      'metrics'       => $winlogbeat::metrics,
      'event_logs'    => $winlogbeat::event_logs_final,
    },
    'output'            => $winlogbeat::outputs,
    'shipper'           => $winlogbeat::shipper,
    'logging'           => $winlogbeat::logging,
    'runoptions'        => $winlogbeat::run_options,
  })

  case $::kernel {
    'Windows' : {
      $cmd_install_dir = regsubst($winlogbeat::install_dir, '/', '\\', 'G')
      $winlogbeat_path = join([$cmd_install_dir, 'Winlogbeat', 'winlogbeat.exe'], '\\')
      $validate_cmd    = $winlogbeat::major_version ? {
        '7'     => "\"${winlogbeat_path}\" test config -c \"%\"",
        default => "\"${winlogbeat_path}\" -N -configtest -c \"%\"",
      }
      file {'winlogbeat.yml':
        ensure       => file,
        path         => $winlogbeat::config_file,
        content      => template($winlogbeat::real_conf_template),
        validate_cmd => $validate_cmd,
        notify       => Service['winlogbeat'],
      }
    } # end Windows

    default : {
      fail($winlogbeat::kernel_fail_message)
    }
  }
}
