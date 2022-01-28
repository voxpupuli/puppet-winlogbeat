# winlogbeat::install
#
# Manage the installation of Winlogbeat
#
# @summary A private class to manage the installation of Winlogbeat
class winlogbeat::install {
  $filename = regsubst($winlogbeat::real_download_url, '.*\/([^\/]+)\.zip$', '\1')
  $zip_file = join([$winlogbeat::tmp_dir, "${filename}.zip"], '/')
  $install_folder = join([$winlogbeat::install_dir, $winlogbeat::folder_name], '/')
  $version_file = join([$install_folder, $filename], '/')

  Exec {
    provider => powershell,
  }

  case $winlogbeat::ensure {
    'present': {
      if ! defined(File[$winlogbeat::install_dir]) {
        file { $winlogbeat::install_dir:
          ensure => directory,
        }
      }

      # Note: We can use archive for unzip and cleanup, thus removing the following two resources.
      # However, this requires 7zip, which archive can install via chocolatey:
      # https://github.com/voxpupuli/puppet-archive/blob/master/manifests/init.pp#L31
      # I'm not choosing to impose those dependencies on anyone at this time...
      if ($winlogbeat::proxy_address) {
        archive { $zip_file:
          source       => $winlogbeat::real_download_url,
          cleanup      => false,
          creates      => $version_file,
          proxy_server => $winlogbeat::proxy_address,
          before       => Exec["unzip ${filename}"],
        }
      } else {
        # Use file when source is puppet:/// because of archive break zip file
        file { $zip_file:
          source => $winlogbeat::real_download_url,
          before => Exec["unzip ${filename}"],
        }
      }

      exec { "unzip ${filename}":
        command => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path '${winlogbeat::install_dir}')).Copyhere(\$sh.namespace((Convert-Path '${zip_file}')).items(), 16)", # lint:ignore:140chars
        creates => $version_file,
        require => File[$winlogbeat::install_dir],
      }

      # You can't remove the old dir while the service has files locked...
      exec { "stop service ${filename}":
        command => 'Set-Service -Name winlogbeat -Status Stopped',
        creates => $version_file,
        onlyif  => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'winlogbeat\'") {exit 0} else {exit 1}',
        require => Exec["unzip ${filename}"],
      }

      exec { "rename ${filename}":
        command => "Remove-Item '${install_folder}' -Recurse -Force -ErrorAction Error; Rename-Item '${winlogbeat::install_dir}/${filename}' '${install_folder}'", # lint:ignore:140chars
        creates => $version_file,
        require => Exec["stop service ${filename}"],
      }

      exec { "mark ${filename}":
        command => "New-Item '${version_file}' -ItemType file",
        creates => $version_file,
        require => Exec["rename ${filename}"],
      }

      exec { "install ${filename}":
        cwd         => $install_folder,
        command     => './install-service-winlogbeat.ps1',
        refreshonly => true,
        subscribe   => Exec["mark ${filename}"],
        notify      => Class['winlogbeat::service'],
      }
    }
    'absent': {
      # Stop and remove service
      exec { "stop service ${filename}":
        command => 'Set-Service -Name winlogbeat -Status Stopped',
        onlyif  => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'winlogbeat\'") {exit 0} else {exit 1}',
      }

      -> exec { "uninstall ${filename}":
        command => "${install_folder}/uninstall-service-winlogbeat.ps1",
        onlyif  => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'winlogbeat\'") {exit 0} else {exit 1}',
      }

      # Remove folders
      -> file { $install_folder:
        ensure => 'absent',
        force  => true,
      }
    }
    default: {
      fail('ensure must be present or absent')
    }
  }
}
