# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::shells::zsh::powerlevel10k { 'namevar': }
define platform::shells::zsh::powerlevel10k (
  Enum['present', 'absent', 'installed', 'latest', 'purged'] $ensure,
  String $user,
  String $home,
  Boolean $with_oh_my_zsh = false,
  Optional[String] $p10k_config = undef,
) {
  # Base path for powerlevel10k installation
  $p10k_path = $with_oh_my_zsh ? {
    true    => "${home}/.oh-my-zsh/custom/themes/powerlevel10k",
    default => "${home}/powerlevel10k",
  }
  # Clone or ensure powerlevel10k is removed based on $ensure
  if $ensure == 'present' {
    exec { "clone-powerlevel10k-${user}":
      command => "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${p10k_path}",
      unless  => "test -d ${p10k_path}",
      user    => $user,
      path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    }

    # Only add source line if not using with oh-my-zsh, as oh-my-zsh handles this
    if !$with_oh_my_zsh {
      file_line { "source-powerlevel10k-${user}":
        path    => "${home}/.zshrc",
        line    => "source '${p10k_path}/powerlevel10k.zsh-theme'",
        match   => "^source .*/powerlevel10k.zsh-theme\$",
        require => Exec["clone-powerlevel10k-${user}"],
      }
    }

    if $p10k_config {
      exec { "download-p10k-config-${user}":
        command => "curl -o ${home}/.p10k.zsh '${p10k_config}'",
        unless  => "test -f ${home}/.p10k.zsh",
        user    => $user,
        path    => ['/bin', '/usr/bin', '/usr/local/bin'],
        require => Exec["clone-powerlevel10k-${user}"],
      }
    }

    # Ensure .p10k.zsh is present
  } elsif $ensure == 'absent' {
    # Remove the powerlevel10k directory
    file { $p10k_path:
      ensure  => absent,
      force   => true,
      recurse => true,
    }

    file { "${home}/.p10k.zsh":
      ensure => absent,
      user   => $user,
    }
  }
}
