# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::config
class platform::config {
  # Set the timezone
  Notify { "Manage timezone: ${platform::manage_timezone}": }
  if $platform::manage_timezone {
    class { 'platform::utils::timezone':
      timezone => $platform::timezone,
    }
  }

  # Setup startup scripts for supported shells
  class { 'platform::shells::bash':
    managed_startup_scripts_global_dir => $platform::managed_shell_startup_global_dir,
    require                            => Class['platform::install'],
  }

  -> class { 'platform::shells::zsh':
    managed_startup_scripts_global_dir => $platform::managed_shell_startup_global_dir,
    require                            => Class['platform::install'],
  }
  #
  # # Setup domain controls
  # -> class { 'platform::domain::control':
  #   require         => Class['platform::install'],
  #   domain_settings => $platform::domain,
  # }

  # Setup access controls
  -> class { 'platform::access::control':
    domain_settings => $platform::domain,
  }

  # Install users from hiera
  -> class { 'platform::user::control':
    managed_startup_scripts_user_dir => $platform::managed_shell_startup_user_dir,
    require                          => Class['platform::install'],
    users                            => $platform::users,
    domain                           => $platform::domain,
  }
}
