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
    managed_startup_strings_user_dir   => $platform::managed_shell_startup_user_dir,
  }

  include platform::shells::zsh

  # Install users from hiera
  include platform::users
}
