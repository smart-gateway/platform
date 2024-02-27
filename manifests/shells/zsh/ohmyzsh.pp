# Define: platform::shells::zsh::ohmyzsh
#
# This defined type manages the installation and basic configuration of Oh-My-Zsh for a specified user.
# It ensures that Oh-My-Zsh is installed or removed based on the `ensure` parameter and configures the .zshrc
# file with the specified theme and plugins.
#
# Parameters:
#   - ensure: Controls the state of the Oh-My-Zsh installation. Valid options are 'present', 'absent', 'installed', 'latest', and 'purged'.
#   - user: The username for whom Oh-My-Zsh should be configured. This user's home directory is used for installation.
#   - home: The home directory of the specified user.
#   - theme: The Oh-My-Zsh theme to apply. Defaults to 'robbyrussell'.
#   - plugins: An optional array of Oh-My-Zsh plugins to enable. Defaults to ['git'].
#
# Behavior:
#   - When `ensure` is set to 'present', 'installed', or 'latest', Oh-My-Zsh is installed, and the .zshrc file is configured but not replaced if it exists.
#   - Specific lines ensuring the correct environment variables and settings are injected into .zshrc.
#   - When `ensure` is set to 'absent' or 'purged', Oh-My-Zsh and the .zshrc file are removed from the user's home directory.
define platform::shells::zsh::ohmyzsh (
  Enum['present', 'absent', 'installed', 'latest', 'purged'] $ensure,
  String $user,
  String $home,
  String $user_scripts_dir,
  String $theme = 'robbyrussell',
  Optional[Array[String]] $plugins = ['git']
) {
  if $ensure == 'present' {
    # Install oh-my-zsh
    exec { "install-oh-my-zsh-${user}":
      command => "sh -c \"$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --keep-zshrc\"",
      creates => "${home}/.oh-my-zsh",
      user    => $user,
      path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    }

    # Exec resource to clone Antidote repository
    exec { "clone-antidote-for-${user}":
      command => "git clone --depth=1 https://github.com/mattmc3/antidote.git ${home}/.antidote",
      creates => "${home}/.antidote",
      user    => $user,
      path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    }

    # Ensure the oh-my-zsh settings are in the user-script-dir
    file { "${user_scripts_dir}/09-puppet-ohmyzsh.sh":
      ensure  => file,
      content => epp('platform/shells/zsh/ohmyzsh/09-puppet-ohmyzsh.sh.epp', { 'theme' => $theme, 'plugins' => [] }),
    }

    # Ensure the antidote plugin manager script is in the user-script-dir
    file { "${user_scripts_dir}/09-puppet-antidote.sh":
      ensure  => file,
      content => epp('platform/shells/zsh/ohmyzsh/09-puppet-antidote.sh.epp'),
    }

    file { "${home}/.zsh_plugins.txt":
      ensure  => file,
      content => epp('platform/shells/zsh/ohmyzsh/.zsh_plugins.txt.epp', { 'plugins' => $plugins }),
    }
  } elsif $ensure == 'absent' {
    # Remove oh-my-zsh
    file { "${home}/.oh-my-zsh":
      ensure  => absent,
      force   => true,
      recurse => true,
    }

    # Remove antidote
    file { "${home}/.antidote":
      ensure  => absent,
      force   => true,
      recurse => true,
    }

    file { "${user_scripts_dir}/09-puppet-ohmyzsh.sh":
      ensure => absent,
    }

    # TODO: This section was removed because we can't assume that not having oh-my-zsh, or more specifically having it
    #   set to be absent means that we don't have anything else that is using or managing the .zshrc file. Ideally
    #   in the future if we get more sophisticated file management we can push/pull specific lines but for now we
    #   should just leave it alone.
    # TODO: WE DO NEED TO TEST WHAT THIS MEANS IF WE HAVE oh-my-zsh enabled then absent do we get errors from the .zshrc?
    # Remove .zshrc file
    # file { "${home}/.zshrc":
    #   ensure => absent,
    # }
  }
}
