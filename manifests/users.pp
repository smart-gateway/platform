# Class: platform::users
#
# This class manages user accounts on the system. It allows for the creation and management
# of user accounts based on a provided hash of user details. Additionally, it offers the option
# to manage the home directories for these user accounts.
#
# Parameters:
#   - users: A hash where each key represents a username with its value being a hash of user attributes.
#            The user attributes hash example is shown below with comments. The below example is hiera
#            however these values could be used in creation of a hash directly in manifest code also.
#            Example:
#               users:
#                 username:
#                   ensure: present or absent
#                   comment: [optional] comment for the user account
#                   password: salted sha512 crypt [ to generate: python -c 'import crypt; print(crypt.crypt("somesecret", crypt.mksalt(crypt.METHOD_SHA512)))' ]
#                   groups: [optional] array of groups in which the user has membership
#                   shell: [optional | default bash] users preferred shell - supported are 'bash', 'zsh', and 'sh'
#                   managehome: [optional | default yes] set to yes or no and controls if Puppet should create and remove the home directory when the user is created and removed
#                   has-files: false
#                   keys: [optional] hash
#                     hash_key_name:
#                       key_type: ed25519 or rsa
#                       key_value: <ssh_key_value>
#   - manage_home_default: A boolean value that determines the default value for managing the home directories for the user accounts.
#                  If set to true, Puppet will ensure that the home directories are created or removed as needed,
#                  based on the user's ensure attribute. Defaults to true.
#
# Usage:
#   To use this class, declare it in your manifest with the desired parameters. For example:
#
#     class { 'platform::users':
#       users => {
#         'johndoe' => { 'ensure' => 'present', 'uid' => '1001', 'shell' => '/bin/bash', 'home' => '/home/johndoe' },
#         'janedoe' => { 'ensure' => 'present', 'uid' => '1002', 'shell' => '/bin/zsh', 'home' => '/home/janedoe' },
#       },
#       manage_home_default => true,
#     }
#
# Note:
#   Ensure that the provided user details match the expected format and that the specified attributes
#   are valid for the user resource type. The manage_home_default parameter should be carefully considered in
#   environments where home directory management is handled externally or where special configurations
#   are required.
class platform::users (
  Hash $users = {},
  String $managed_startup_scripts_user_dir,
  Boolean $manage_home_default = true,
) {
  $platform::users.each | $username, $details | {
    # Get the manage_home value from the user or use the default
    $manage_home = $details[managehome] == undef ? {
      true    => $manage_home_default,
      default => $details[managehome],
    }

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
      file { $filename:
        ensure  => file,
        source  => $file_details['source'],
        mode    => $file_details['mode'],
        user    => $username,
        group   => $username,
        replace => !$file_details['create_only'],
      }
    }
  }
}
