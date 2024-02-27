# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::config
class platform::config {
  # Setup startup scripts for supported shells
  class { 'platform::shells::bash':
    managed_startup_scripts_global_dir => $platform::managed_shell_startup_global_dir,
    require                            => Class['platform::install'],
  }

  -> class { 'platform::shells::zsh':
    managed_startup_scripts_global_dir => $platform::managed_shell_startup_global_dir,
    require                            => Class['platform::install'],
  }

  # Setup access controls
  -> class { 'platform::access::control':
    require                            => Class['platform::install'],
  }

  # Install users from hiera
  -> class { 'platform::user::control':
    managed_startup_scripts_user_dir => $platform::managed_shell_startup_user_dir,
    require                          => Class['platform::install'],
  }
}
