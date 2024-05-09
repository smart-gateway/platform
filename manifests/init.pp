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
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure_platform_exporter = 'present',
  String $platform_exporter_binary_location = '/usr/local/bin/puppet-agent-exporter',
  String $managed_shell_startup_global_dir = '/etc/%src.managed.d', # these strings have a format string in them so different shells can use them
  String $managed_shell_startup_user_dir = '.%src.managed.d', # these strings have a format string in them so different shells can use them
  Boolean $manage_timezone = true,
  String $allow_password_over_ssh = 'no',
  String $timezone = 'America/Los_Angeles',
  Hash $users = {},
  Hash $domain = {},
  Hash $packages = {},
  Hash $hosts_entries = {},
  Hash $ntp = {},
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
  } elsif $facts['kernel'] == 'windows' {
    # TODO: This is temporary, ideally the main flow above would support Windows and Linux. For now the Windows support isn't needed so no time has been given to enabling it
    if $platform::manage_timezone {
      class { 'platform::utils::timezone':
        timezone => $platform::timezone,
      }
    }
  }
}
