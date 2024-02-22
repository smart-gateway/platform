# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::shells::bash { 'namevar': }
define platform::shells::bash_user (
  String $managed_startup_scripts_user_dir,
  Boolean $manage_startup_scripts = true,
  Hash $shell_options = {},
) {
  # Setup startup scripts
  if $manage_startup_scripts {
    $user_scripts_dir = sprintf($managed_startup_scripts_user_dir, 'bash')

    # Ensure user directory exists
    file { $user_scripts_dir:
      ensure => directory,
      purge  => true,
    }
  }
}
