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
  String $theme = 'robbyrussell',
  Optional[Array[String]] $plugins = ['git']
) {
  if $ensure == 'present' {
    # Install oh-my-zsh
    exec { "install-oh-my-zsh-${user}":
      command => "sh -c \"$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended\"",
      creates => "${home}/.oh-my-zsh",
      user    => $user,
      path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    }

    # Ensure .zshrc exists - don't replace it if the contents just don't match
    file { "ensure_${home}_has_zshrc_template_for_ohmyzsh":
      ensure => file,
      path   => "${home}/.zshrc",
      owner    => $user,
      group    => $user,
      replace  => false,
      content  => template('platform/shells/zsh/ohmyzsh/zshrc.erb'),
      require  => Exec["install-oh-my-zsh-${user}"],
    }

    # Ensure lines are in .zshrc
    file_line { 'zsh_export':
      path  => "${home}/.zshrc",
      line  => 'export ZSH=$HOME/.oh-my-zsh',
      match => '^export ZSH=',
    }

    file_line { 'zsh_theme':
      path  => "${home}/.zshrc",
      line  => "ZSH_THEME=\"${theme}\"",
      match => '^ZSH_THEME=',
    }

    file_line { 'zsh_plugins':
      path  => "${home}/.zshrc",
      line  => "plugins=(${plugins.join(' ')})",
      match => '^plugins=\(',
    }

    file_line { 'zsh_source':
      path  => "${home}/.zshrc",
      line  => 'source $ZSH/oh-my-zsh.sh',
      match => '^source \$ZSH/oh-my-zsh.sh',
    }
  } elsif $ensure == 'absent' {
    # Remove oh-my-zsh
    file { "${home}/.oh-my-zsh":
      ensure  => absent,
      force   => true,
      recurse => true,
    }

    # Remove .zshrc file
    file { "${home}/.zshrc":
      ensure => absent,
    }
  }
}
