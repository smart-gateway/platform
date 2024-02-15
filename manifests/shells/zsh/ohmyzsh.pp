# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::shells::zsh::ohmyzsh { 'namevar': }
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
    file { "${home}/.zshrc":
      ensure  => file,
      owner   => $user,
      group   => $user,
      replace => false,
      content => template('platform/shells/zsh/ohmyzsh/zshrc.erb'),
      require => Exec["install-oh-my-zsh-${user}"],
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
      line  => "plugins=(${plugins.join(', ')})",
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
      user    => $user,
    }

    # Remove .zshrc file
    file { "${home}/.zshrc":
      ensure => absent,
      user   => $user,
    }
  }
}
