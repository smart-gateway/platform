# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::utils::timezone
class platform::utils::timezone (
  String $timezone
) {
  # Mapping of common timezone IDs to Windows Timezone IDs
  $windows_timezone_map = {
    'America/Los_Angeles' => 'Pacific Standard Time',
    'America/New_York'    => 'Eastern Standard Time',
    'America/Chicago'     => 'Central Standard Time',
    'America/Denver'      => 'Mountain Standard Time',
    'UTC'                 => 'UTC',
    # Add more mappings as necessary
  }

  # Determine the appropriate timezone setting based on the OS
  case $facts['kernel'] {
    'Linux': {
      file { '/etc/localtime':
        ensure => link,
        target => "/usr/share/zoneinfo/${timezone}",
        force  => true,
        notify => Exec['set_hwclock'],
      }

      exec { 'set_hwclock':
        command     => 'hwclock --systohc',
        refreshonly => true,
        path        => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
      }
    }
    'windows': {
      # Use the mapping if available, otherwise default to the provided timezone
      $windows_timezone = $windows_timezone_map[$timezone] ? {
        undef   => $timezone,
        default => $windows_timezone_map[$timezone],
      }

      exec { 'set_windows_timezone':
        command  => "Set-TimeZone -Id \"${windows_timezone}\"",
        provider => powershell,
        unless   => "if ((Get-Timezone).Id -eq '${windows_timezone}') { exit 0 } else { exit 1 }",
      }
    }
    default: {
      notify { 'Unsupported OS':
        message => "The set_timezone class does not support the ${facts['kernel']} operating system.",
      }
    }
  }
}
