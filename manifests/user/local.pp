# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::user::local { 'namevar': }
define platform::user::local (
  String $username,
  Hash $details,
  Boolean $manage_home,
  String $managed_startup_scripts_user_dir,
) {
  # Handle conversion of the shell value from Hiera into the actual shell
  $shell = $details['shell'] ? {
    /^(sh|\/bin\/sh)$/      => '/bin/sh',
    /^(zsh|\/bin\/zsh)$/    => '/bin/zsh',
    /^(ksh|\/bin\/ksh)$/    => '/bin/ksh',
    /^(bash|\/bin\/bash|)$/ => '/bin/bash',
    default                 => fail("Unsupported shell: ${details['shell']}")
  }

  # Create user
  user { $username:
    ensure     => $details[ensure],
    comment    => $details[comment],
    password   => $details[password],
    managehome => $manage_home,
    groups     => $details[groups],
    shell      => $shell,
  }

  # Define the path to the authorized_keys file
  $home_dir = "/home/${username}"
  $ssh_directory = "${home_dir}/.ssh"
  $authorized_keys_path = "${ssh_directory}/authorized_keys"

  # Ensure the authorized_keys file exists
  file { "ensure_${username}_ssh_directory_exists":
    ensure => directory,
    path   => $ssh_directory,
    owner  => $username,
    group  => $username,
    mode   => '0700',
  }
  -> file { "ensure_${username}_authorized_keys_exists":
    ensure => file,
    path   => $authorized_keys_path,
    owner  => $username,
    group  => $username,
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

  # Add any GitHub or Launchpad keys
  $ids = get($details, 'import-keys', {})
  $ids.each | String $key_id | {
    platform::utils::import_ssh_keys { "import_${username}_keys_from_${key_id}":
      id                   => $key_id,
      user                 => $username,
      authorized_keys_path => $authorized_keys_path,
      require              => File["ensure_${username}_authorized_keys_exists"],
    }
  }

  # Setup shell
  $shell_opts = get($details, 'shell-options', {})
  $zsh_options = get($shell_opts, 'zsh', {})
  $bash_options = get($shell_opts, 'bash', {})
  $sh_options = get($shell_opts, 'sh', {})

  # Run initialization for each shell so that the user can move back and forth with consistency
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

  # Ensure users sh customizations are executed
  # TODO

  # Handle any custom files
  $files = get($details, 'files', {})
  $files.each |String $filename, Hash $file_details| {
    file { "${home_dir}/${filename}":
      ensure  => file,
      source  => $file_details['source'],
      mode    => $file_details['mode'],
      owner   => $username,
      group   => $username,
      replace => !$file_details['create_only'],
    }
  }
}
