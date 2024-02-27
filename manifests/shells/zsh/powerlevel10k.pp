# Define: platform::shells::zsh::powerlevel10k
#
# This defined type manages the installation and configuration of the Powerlevel10k theme for Zsh,
# either as a standalone theme or as part of the Oh-My-Zsh framework. It supports downloading a custom
# Powerlevel10k configuration from a provided URL.
#
# Parameters:
#   - ensure: Specifies the desired state of the Powerlevel10k theme ('present', 'absent', 'installed', 'latest', 'purged').
#   - user: The username for whom the Powerlevel10k theme should be configured.
#   - home: The home directory of the specified user.
#   - with_oh_my_zsh: Indicates whether Powerlevel10k should be integrated with Oh-My-Zsh.
#   - p10k_config: Optional URL from where the Powerlevel10k configuration (.p10k.zsh) can be downloaded.
#
# Behavior:
#   - When `ensure` is 'present', 'installed', or 'latest', the Powerlevel10k theme is cloned into the appropriate directory,
#     and the .zshrc file is configured to source the theme. If a `p10k_config` URL is provided, the configuration file
#     is downloaded to the user's home directory.
#   - Specific lines required by Powerlevel10k for instant prompt functionality are ensured in the .zshrc file.
#   - When `ensure` is 'absent' or 'purged', the Powerlevel10k theme directory and the configuration file are removed.
define platform::shells::zsh::powerlevel10k (
  Enum['present', 'absent', 'installed', 'latest', 'purged'] $ensure,
  String $user,
  String $home,
  String $user_scripts_dir,
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
      file_line { "source_powerlevel10k_${user}":
        path  => "${home}/.zshrc.managed.d/10-puppet-powerlevel10k.sh",
        line  => "source '${p10k_path}/powerlevel10k.zsh-theme'",
        match => "^source .*/powerlevel10k.zsh-theme\$",
      }
    } else {
      # Create file for instantprompt
      file { "${user_scripts_dir}/10-puppet-powerlevel10k.sh":
        ensure  => file,
        content => epp('platform/shells/zsh/powerlevel10k/10-puppet-powerlevel10k.sh.epp'),
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
  } elsif $ensure == 'absent' {
    # Remove the powerlevel10k directory
    file { $p10k_path:
      ensure  => absent,
      force   => true,
      recurse => true,
    }

    file { "${home}/.p10k.zsh":
      ensure => absent,
    }

    file { "${user_scripts_dir}/10-puppet-powerlevel10k.sh":
      ensure  => absent,
    }

    # # Remove lines from .zshrc if it exists
    # platform::utils::remove_line { 'remove_p10k_instant_prompt_comment':
    #   filename => "${home}/.zshrc",
    #   line     => '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.',
    #   match    => '^# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.',
    # }
    #
    # platform::utils::remove_line { 'remove_p10k_instant_prompt_comment2':
    #   filename => "${home}/.zshrc",
    #   line     => '# Initialization code that may require console input (password prompts, [y/n]',
    #   match    => '^# Initialization code that may require console input \(password prompts, \[y/n\]',
    # }
    #
    # platform::utils::remove_line { 'remove_p10k_instant_prompt_comment3':
    #   filename => "${home}/.zshrc",
    #   line     => '# confirmations, etc.) must go above this block; everything else may go below.',
    #   match    => '^# confirmations, etc.\) must go above this block; everything else may go below.',
    # }
    #
    # platform::utils::remove_line { 'remove_p10k_instant_prompt':
    #   filename => "${home}/.zshrc",
    #   line     => 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then',
    #   match    => '^if \[\[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${\(%\):-%n}.zsh" \]\]; then',
    # }
    #
    # platform::utils::remove_line { 'remove_p10k_instant_prompt_source':
    #   filename => "${home}/.zshrc",
    #   line     => '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"',
    #   match    => '^  source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${\(%\):-%n}.zsh"',
    # }
    #
    # platform::utils::remove_line { 'remove_p10k_instant_prompt_end':
    #   filename => "${home}/.zshrc",
    #   line     => 'fi',
    #   match    => '^fi',
    # }
    #
    # platform::utils::remove_line { 'remove_p10k_configure_comment':
    #   filename => "${home}/.zshrc",
    #   line     => '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.',
    #   match    => '^# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.',
    # }
    #
    # platform::utils::remove_line { 'remove_p10k_source_config':
    #   filename => "${home}/.zshrc",
    #   line     => '\[\[ ! -f ~/.p10k.zsh \]\] || source ~/.p10k.zsh',
    #   match    => '^\[\[ ! -f ~/.p10k.zsh \]\] \|\| source ~/.p10k.zsh',
    # }
    #
    # platform::utils::remove_line { 'remove_p10k_source_theme':
    #   filename => "${home}/.zshrc",
    #   line     => "source '/home/ben/powerlevel10k/powerlevel10k.zsh-theme\'",
    #   match    => "^source '/home/ben/powerlevel10k/powerlevel10k.zsh-theme\'",
    # }
  }
}
