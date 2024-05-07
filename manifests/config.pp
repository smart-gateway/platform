# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::config
class platform::config {
  # Set the timezone
  if $platform::manage_timezone {
    class { 'platform::utils::timezone':
      timezone => $platform::timezone,
    }
  }

  # Setup hosts entries
  $hosts_entries = $platform::hosts_entries
  $hosts_entries.each |$host, $settings| {
    platform::utils::hosts_entry { $host:
      ip      => $settings[ip],
      aliases => $settings[aliases],
      comment => $settings[comment],
    }
  }

  # Setup ntp service
  class { 'platform::utils::ntp':
    ntp_servers => $platform::ntp['servers'],
  }

  # Setup startup scripts for supported shells
  class { 'platform::shells::bash':
    managed_startup_scripts_global_dir => $platform::managed_shell_startup_global_dir,
    require                            => Class['platform::install'],
    tag                                => ['bash', 'shells'],
  }

  -> class { 'platform::shells::zsh':
    managed_startup_scripts_global_dir => $platform::managed_shell_startup_global_dir,
    require                            => Class['platform::install'],
    tag                                => ['zsh', 'shells'],
  }

  # Setup access controls
  -> class { 'platform::access::control':
    domain_settings         => $platform::domain,
    allow_password_over_ssh => $platform::allow_password_over_ssh,
    tag                     => ['access', 'domain'],
  }

  # Install users from hiera
  -> class { 'platform::user::control':
    managed_startup_scripts_user_dir => $platform::managed_shell_startup_user_dir,
    require                          => Class['platform::install'],
    users                            => $platform::users,
    domain                           => $platform::domain,
    tag                              => ['users'],
  }

  # Run cleanup class
  class { 'platform::utils::cleanup':
  }
}
