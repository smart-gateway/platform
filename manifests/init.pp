# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform
class platform (
  String $cluster,
  String $project,
  String $project_id,
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure_netcheck = 'present',
  String $netcheck_binary_location = '/usr/local/bin/netcheck',
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure_puppet_exporter = 'present',
  String $puppet_exporter_binary_location = '/usr/local/bin/puppet-agent-exporter',
  String $managed_shell_startup_global_dir = '/etc/%src.managed.d', # these strings have a format string in them so different shells can use them
  String $managed_shell_startup_user_dir = '.%src.managed.d', # these strings have a format string in them so different shells can use them
  Boolean $manage_timezone = true,
  String $timezone = 'America/Los_Angeles',
  Hash $users = {},
  Hash $domain = {},
  Hash $packages = {},
) {
  if $facts['kernel'] ==  'Linux' {
    contain platform::prep
    contain platform::install
    contain platform::config
    contain platform::service

    # Order of class application
    Class['platform::prep']
    -> Class['platform::install']
    -> Class['platform::config']
    -> Class['platform::service']
  }
}
