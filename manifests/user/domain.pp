# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::user::domain { 'namevar': }
define platform::user::domain (
  String $username,
  Hash $details,
  Boolean $manage_home,
  String $managed_startup_scripts_user_dir,
) {
  # Run initialization for each shell so that the user can move back and forth with consistency
  $home_dir = "/home/${username}"
  $ssh_directory = "${home_dir}/.ssh"
  $authorized_keys_path = "${ssh_directory}/authorized_keys"

  # Ensure users bash customizations are executed
  platform::shells::bash_user { "bash_user_${username}":
    username                         => $username,
    home_dir                         => $home_dir,
    managed_startup_scripts_user_dir => $managed_startup_scripts_user_dir,
    shell_options                    => $bash_options,
  }

  # Ensure users zsh customizations are executed
  platform::shells::zsh_user { "zsh_user_${username}":
    username                         => $username,
    home_dir                         => $home_dir,
    managed_startup_scripts_user_dir => $managed_startup_scripts_user_dir,
    shell_options                    => $zsh_options,
  }
}
