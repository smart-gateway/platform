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
}
