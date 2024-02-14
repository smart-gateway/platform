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
  String $netcheck_binary_location = '/usr/local/bin/netcheck',
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure_puppet_exporter = 'present',
  String $puppet_exporter_binary_location = '/usr/local/bin/puppet-agent-exporter',
  Hash $users = {},
  Hash $packages = {},
) {
  contain platform::install
  contain platform::config
  contain platform::service

  # Do pre-install tasks
  platform::utils::update_package_manager { 'platform::ensure_package_manager_is_updated': }

  # Order of class application
  Class['platform::install'] ->
  Class['platform::config'] ->
  Class['platform::service']
}
