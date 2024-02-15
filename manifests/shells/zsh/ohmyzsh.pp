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
  Notify { "setting up oh-my-zsh for ${user} in ${home} with theme ${theme}": }
}
