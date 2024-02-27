# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::shells::zsh::plugin { 'namevar': }
define platform::shells::zsh::plugin (
  String $plugin_name,
  String $source,
  String $location,
) {
  exec { "clone-${plugin_name}-${location}":
    command => "git clone --depth=1 ${source} ${location}/${plugin_name}",
    unless  => "test -d ${location}/${plugin_name}",
    user    => $user,
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
  }
}
