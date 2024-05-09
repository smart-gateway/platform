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
    tag    => ['tools', 'install'],
  }

  # Install puppet agent exporter for prometheus monitoring
  platform::utils::manage_file { 'platform::platform_exporter':
    ensure => $platform::ensure_platform_exporter,
    source => 'puppet:///modules/platform/tools/exporter/platform_exporter',
    path   => $platform::platform_exporter_binary_location,
    notify => Platform::Utils::Manage_service['platform_exporter'],
    tag    => ['tools', 'install'],
  }

  # Ensure shells and needed tools are installed
  $tools_packages = ['zsh', 'git', 'curl']

  # Iterate over the array to ensure each package is installed
  $tools_packages.each | String $package_name | {
    platform::packages::package { "platform::ensure_${package_name}_installed":
      ensure       => 'latest',
      package_name => $package_name,
      tag          => ['tools', 'shells', 'install'],
    }
  }

  # Ensure ssh import tools are installed
  platform::packages::package { 'platform::ensure_ssh_import_id':
    ensure       => 'latest',
    package_name => 'ssh-import-id',
    tag          => ['tools', 'install'],
  }

  # Ensure packages needed for domain are installed
  $domain_packages = ['sssd-ad', 'sssd-tools', 'realmd', 'adcli', 'libsss-sudo', 'sssd-dbus', 'msktutil', 'krb5-user']

  # Iterate over the array to ensure each package is installed
  $domain_packages.each | String $package_name | {
    platform::packages::package { "platform::ensure_${package_name}_installed":
      ensure       => 'latest',
      package_name => $package_name,
      tag          => ['tools', 'install', 'domain'],
    }
  }

  # Install packages from hiera
  include platform::packages
}
