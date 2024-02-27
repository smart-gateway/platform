# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::shells::zsh::plugin { 'namevar': }
define platform::shells::zsh::plugin (
  String $name,
  String $source,
  String $location,
) {
  exec { "clone-${name}-${location}":
    command => "git clone --depth=1 ${source} ${location}/${name}",
    unless  => "test -d ${location}/${name}",
    user    => $user,
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
  }
}
