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

  $shell_opts = get($details, 'shell-options', {})
  $zsh_options = get($shell_opts, 'zsh', {})
  $bash_options = get($shell_opts, 'bash', {})
  $sh_options = get($shell_opts, 'sh', {})

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

  # Handle any custom files
  $home_directories = $facts['home_directories']
  if $home_dir in $home_directories {
    # Ensure the authorized_keys file exists
    file { "ensure_${username}_ssh_directory_exists":
      ensure => directory,
      path   => $ssh_directory,
      owner  => $username,
      group  => 'domain users',
      mode   => '0700',
    }
    -> file { "ensure_${username}_authorized_keys_exists":
      ensure => file,
      path   => $authorized_keys_path,
      owner  => $username,
      group  => 'domain users',
      mode   => '0600',
    }

    # Add authorized keys for the user and import any GitHub or Launchpad keys
    $keys = get($details, 'keys', {})
    $keys.each | $key_name, $key_details | {
      ssh_authorized_key { "${username}_${key_name}":
        ensure  => $key_details[ensure],
        user    => $username,
        type    => "ssh-${key_details[key_type]}",
        key     => $key_details[key_value],
        require => File["ensure_${username}_authorized_keys_exists"],
      }
    }

    $files = get($details, 'files', {})
    $files.each |String $filename, Hash $file_details| {
      file { "${home_dir}/${filename}":
        ensure  => file,
        source  => $file_details['source'],
        mode    => $file_details['mode'],
        owner   => $username,
        group   => 'domain users',
        replace => !$file_details['create_only'],
      }
    }
  }
}
