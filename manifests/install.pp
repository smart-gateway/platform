# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::install
class platform::install {

  platform::manage_file { 'platform::netcheck_file':
    ensure_state => $::platform::ensure_netcheck,
    source       => 'puppet:///modules/platform/tools/netcheck/netcheck.py',
    path         => '/usr/local/bin/netcheck',
  }

  platform::manage_file { 'platform::puppet_exporter_file':
    ensure_state => $::platform::ensure_puppet_exporter,
    source       => 'puppet:///modules/platform/tools/exporter/puppet-agent-exporter',
    path         => '/usr/local/bin/puppet-agent-exporter',
    notify       => Service['platform::puppet-agent-exporter'],
  }

}
