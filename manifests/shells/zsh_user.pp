# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::shells::zsh { 'namevar': }
define platform::shells::zsh_user (
  String $home_dir,
  String $managed_startup_scripts_user_dir,
  Boolean $manage_startup_scripts = true,
  Hash $shell_options = {},
) {
  # Boolean $zsh_autosuggestions = false,
  # Boolean $zsh_syntax_highlighting = false,
  # Boolean $zsh_history_substring_search = false,
  # Boolean $oh_my_zsh = false,
  # Boolean $powerlevel10k = false,
  # Boolean $zsh_completions = false,
  # Boolean $antigen = false,
  # Boolean $zplug = false,
  # Boolean $autojump = false,
  # Boolean $spaceship_prompt = false,
  # Boolean $zsh_vi_mode = false,
  # Boolean $fzf = false,
  # Boolean $pure = false,
  # Boolean $fast_syntax_highlighting = false,
  # Boolean $zsh_async = false,
  # Setup startup scripts
  if $manage_startup_scripts {
    $user_scripts_dir = sprintf("${home_dir}/${managed_startup_scripts_user_dir}", 'zsh')

    # Ensure user directory exists
    file { $user_scripts_dir:
      ensure => directory,
      purge  => true,
    }

    # Ensure their .profile file is managed
    file { "${home_dir}/.zprofile":
      ensure  => file,
      content => epp('platform/shells/zsh/user/.zprofile.epp'),
    }

    # Ensure their .zshrc file exists (don't manage)
    file { "${home_dir}/.zshrc":
      ensure  => file,
      content => epp('platform/shells/zsh/user/.zshrc.epp'),
      replace => false,
    }

    # Add line to their .zshrc
    exec { "add_init_to_${home_dir}/.zshrc":
      command => "sed -i '1i[ -d \"\$HOME/.zshrc.managed.d\" ] && [ -f \"\$HOME/.zshrc.managed.d/.init.sh\" ] && source \"\$HOME/.zshrc.managed.d/.init.sh\"' ${home_dir}/.zshrc",
      path    => ['/bin', '/usr/bin'],
      unless  => "grep -q 'source \"\$HOME/.zshrc.managed.d/.init.sh\"' ${home_dir}/.zshrc",
    }

    # Ensure the init file is present
    file { "${user_scripts_dir}/.init.sh":
      ensure  => file,
      content => epp('platform/shells/zsh/user/.init.sh.epp'),
    }

    # Setup any shell options
    $shell_opts.each | $option_key, $option_details | {
      case $option_key {
        'oh-my-zsh': {
          platform::shells::zsh::ohmyzsh { $option_key:
            user => $username,
            home => $home_dir,
            *    => $option_details,
          }
        }
        'powerlevel10k': {
          platform::shells::zsh::powerlevel10k { $option_key:
            user             => $username,
            home             => $home_dir,
            user_scripts_dir => $user_scripts_dir,
            *                => $option_details,
          }
        }
        default: {
          warning("Unsupported shell option '${option_key}'")
        }
      }
    }
  }
}
