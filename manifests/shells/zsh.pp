# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::shells::zsh
class platform::shells::zsh (
  String $managed_startup_scripts_global_dir,
  String $system_path = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin',
  Boolean $manage_startup_scripts = true,
) {
  if $manage_startup_scripts {
    $global_scripts_dir = sprintf($managed_startup_scripts_global_dir, 'zsh')

    # Ensure global directory exists
    file { $global_scripts_dir:
      ensure => directory,
      purge  => true,
    }

    # Modify skel files
    file { '/etc/skel/.zshrc':
      ensure  => file,
      content => epp('platform/shells/zsh/etc/skel/zshrc.epp'),
    }

    file { '/etc/skel/.zprofile':
      ensure  => file,
      content => epp('platform/shells/zsh/etc/skel/zprofile.epp'),
    }

    # Modify global configuration files
    file { '/etc/zshenv':
      ensure  => file,
      content => epp('platform/shells/zsh/etc/zshenv.epp', { 'path' => $system_path }),
    }

    file { '/etc/zprofile':
      ensure  => file,
      content => epp('platform/shells/zsh/etc/zprofile.epp'),
    }

    file { '/etc/zshrc':
      ensure  => file,
      content => epp('platform/shells/zsh/etc/zshrc.epp', { 'directory' => $global_scripts_dir }),
    }
  }
}
