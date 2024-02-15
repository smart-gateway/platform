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

  # Install Netcheck tool
  platform::utils::manage_file { 'platform::netcheck_file':
    ensure => $platform::ensure_netcheck,
    source => 'puppet:///modules/platform/tools/netcheck/netcheck.py',
    path   => $platform::netcheck_binary_location,
  }

  # Install puppet agent exporter for prometheus monitoring
  platform::utils::manage_file { 'platform::puppet_exporter_file':
    ensure => $platform::ensure_puppet_exporter,
    source => 'puppet:///modules/platform/tools/exporter/puppet-agent-exporter',
    path   => $platform::puppet_exporter_binary_location,
    notify => Platform::Utils::Manage_service['puppet_agent_exporter'],
  }

  # Ensure shells and needed tools are installed
  platform::packages::package { 'platform::ensure_zsh_installed':
    ensure       => 'latest',
    package_name => 'zsh',
  }
  platform::packages::package { 'platform::ensure_git_installed':
    ensure       => 'latest',
    package_name => 'git',
  }
  platform::packages::package { 'platform::ensure_curl_installed':
    ensure       => 'latest',
    package_name => 'curl',
  }

  # Ensure ssh import tools are installed
  platform::packages::package { 'platform::ensure_ssh_import_id':
    ensure       => 'latest',
    package_name => 'ssh-import-id',
  }

  # Install packages from hiera
  include platform::packages
}
