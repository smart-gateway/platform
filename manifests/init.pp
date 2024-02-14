# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform
class platform(
  String $cluster,
  String $project,
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure_netcheck = 'present',
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure_puppet_exporter = 'present',
  Hash $users = {},
  Hash $packages = {},
) {
  contain platform::install
  contain platform::config
  contain platform::service

  # Order of class application
  Class['platform::install'] ->
  Class['platform::config'] ->
  Class['platform::service']
}
