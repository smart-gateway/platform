# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::install
class platform::install {

  ######################################################################################################################
  ## INSTALL COMMON TOOLS, PACKAGES AND UTILITIES
  ######################################################################################################################
  platform::utils::manage_file { 'platform::netcheck_file':
    ensure => $::platform::ensure_netcheck,
    source       => 'puppet:///modules/platform/tools/netcheck/netcheck.py',
    path         => $::platform::netcheck_binary_location,
  }

  platform::utils::manage_file { 'platform::puppet_exporter_file':
    ensure => $::platform::ensure_puppet_exporter,
    source       => 'puppet:///modules/platform/tools/exporter/puppet-agent-exporter',
    path         => $::platform::puppet_exporter_binary_location,
    notify       => Platform::Utils::Manage_service['puppet_agent_exporter'],
  }

  include platform::packages
}
