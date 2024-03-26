# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::shells::bash
class platform::shells::bash (
  String $managed_startup_scripts_global_dir,
  String $system_path = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin',
  Boolean $manage_startup_scripts = true,
) {
  if $manage_startup_scripts {
    $global_scripts_dir = sprintf($managed_startup_scripts_global_dir, 'bash')

    # Ensure global directory exists
    file { $global_scripts_dir:
      ensure => directory,
      purge  => true,
    }

    # Modify skel files
    file { '/etc/skel/.bashrc':
      ensure  => file,
      content => epp('platform/shells/bash/etc/skel/.bashrc.epp'),
    }

    file { '/etc/skel/.profile':
      ensure  => file,
      content => epp('platform/shells/bash/etc/skel/.profile.epp'),
    }

    # Modify global configuration files
    file { '/etc/environment':
      ensure  => file,
      content => epp('platform/shells/bash/etc/environment.epp', { 'path' => $system_path }),
    }

    file { '/etc/profile':
      ensure  => file,
      content => epp('platform/shells/bash/etc/profile.epp'),
    }

    file { '/etc/bash.bashrc':
      ensure  => file,
      content => epp('platform/shells/bash/etc/bash.bashrc.epp', { 'directory' => $global_scripts_dir }),
    }
  }
}
