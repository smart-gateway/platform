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

    # If p10k_config is set then download the configuration file
    if $p10k_config {
      exec { "download-p10k-config-${user}":
        command => "curl -o ${home}/.p10k.zsh '${p10k_config}'",
        unless  => "test -f ${home}/.p10k.zsh",
        user    => $user,
        path    => ['/bin', '/usr/bin', '/usr/local/bin'],
        require => Exec["clone-powerlevel10k-${user}"],
      }
    }

    # Make edits to .zshrc that are needed
    file_line { 'p10k_instant_prompt_comment':
      path  => "${home}/.zshrc",
      line  => '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.',
      match => '^# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.',
    }

    file_line { 'p10k_instant_prompt_comment2':
      path  => "${home}/.zshrc",
      line  => '# Initialization code that may require console input (password prompts, [y/n]',
      match => '^# Initialization code that may require console input \(password prompts, \[y/n\]',
    }

    file_line { 'p10k_instant_prompt_comment3':
      path  => "${home}/.zshrc",
      line  => '# confirmations, etc.) must go above this block; everything else may go below.',
      match => '^# confirmations, etc.\) must go above this block; everything else may go below.',
    }

    file_line { 'p10k_instant_prompt':
      path  => "${home}/.zshrc",
      line  => 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then',
      match => '^if \[\[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${\(%\):-%n}.zsh" \]\]; then',
    }

    file_line { 'p10k_instant_prompt_source':
      path  => "${home}/.zshrc",
      line  => '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"',
      match => '^  source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${\(%\):-%n}.zsh"',
    }

    file_line { 'p10k_instant_prompt_end':
      path  => "${home}/.zshrc",
      line  => 'fi',
      match => '^fi',
    }

    file_line { 'p10k_configure_comment':
      path  => "${home}/.zshrc",
      line  => '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.',
      match => '^# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.',
    }

    file_line { 'p10k_source_config':
      path  => "${home}/.zshrc",
      line  => '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh',
      match => '^\[\[ ! -f ~/.p10k.zsh \]\] \|\| source ~/.p10k.zsh',
    }
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
