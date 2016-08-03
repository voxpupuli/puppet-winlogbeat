class winlogbeat::install {
  $filename = regsubst($winlogbeat::download_url, '^https.*\/([^\/]+)\.[^.].*', '\1')
  $foldername = 'winlogbeat'

  file { $winlogbeat::install_dir:
    ensure => directory
  }

  remote_file {"${winlogbeat::tmp_dir}/${filename}.zip":
    ensure      => present,
    source      => $winlogbeat::download_url,
    verify_peer => false,
  }

  exec { "unzip ${filename}":
    command  => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path '${winlogbeat::install_dir}')).Copyhere(\$sh.namespace((Convert-Path '${winlogbeat::tmp_dir}/${filename}.zip')).items(), 16)",
    creates  => "${winlogbeat::install_dir}/winlogbeat",
    provider => powershell,
    require  => [
      File[$winlogbeat::install_dir],
      Remote_file["${winlogbeat::tmp_dir}/${filename}.zip"],
    ],
  }

  exec { 'rename folder':
    command  => "Rename-Item '${winlogbeat::install_dir}/${filename}' winlogbeat",
    creates  => "${winlogbeat::install_dir}/winlogbeat",
    provider => powershell,
    require  => Exec["unzip ${filename}"],
  }

  exec { "install ${filename}":
    cwd      => "${winlogbeat::install_dir}/winlogbeat",
    command  => './install-service-winlogbeat.ps1',
    onlyif   => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'winlogbeat\'") { exit 1 } else {exit 0 }',
    provider =>  powershell,
    require  => Exec['rename folder'],
  }
}