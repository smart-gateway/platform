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
  exec { "install-oh-my-zsh-${user}":
    command => "sh -c \"$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" --unattended",
    creates => "${home}/.oh-my-zsh",
    user    => $user,
    require => Package['zsh'],
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
  }
}
