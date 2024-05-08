# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::shells::bash { 'namevar': }
define platform::shells::bash_user (
  String $username,
  String $user_type,
  String $home_dir,
  String $managed_startup_scripts_user_dir,
  Boolean $manage_startup_scripts = true,
  Hash $shell_options = {},
) {
  $home_directories = $facts['home_directories']

  # Setup startup scripts
  if $manage_startup_scripts and $home_dir in $home_directories {
    $user_scripts_dir = sprintf("${home_dir}/${managed_startup_scripts_user_dir}", 'bash')

    # Ensure user directory exists
    file { $user_scripts_dir:
      ensure => directory,
      purge  => true,
    }

    # Ensure their .profile file is managed
    file { "${home_dir}/.profile":
      ensure  => file,
      content => epp('platform/shells/bash/user/.profile.epp'),
    }

    # Ensure their .bashrc file exist
    $owner = $user_type ? {
      'local' => $username,
      'domain' => 'domain users',
    }
    file { "${home_dir}/.bashrc":
      ensure  => file,
      content => epp('platform/shells/bash/user/.bashrc.epp'),
      replace => false,
      owner   => $username,
      group   => $owner,
    }

    # Add line to their .bashrc
    exec { "add_init_to_${home_dir}/.bashrc":
      command => "sed -i '1i[ -d \"\$HOME/.bashrc.managed.d\" ] && [ -f \"\$HOME/.bashrc.managed.d/.init.sh\" ] && source \"\$HOME/.bashrc.managed.d/.init.sh\"' ${home_dir}/.bashrc",
      path    => ['/bin', '/usr/bin'],
      unless  => "grep -q 'source \"\$HOME/.bashrc.managed.d/.init.sh\"' ${home_dir}/.bashrc",
    }

    # Ensure the init file is present
    file { "${user_scripts_dir}/.init.sh":
      ensure  => file,
      content => epp('platform/shells/bash/user/.init.sh.epp'),
    }
  }
}
