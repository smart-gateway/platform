# Defined Type: platform::utils::update_package_manager
#
# This defined type updates the package manager's cache on various Linux distributions.
# It ensures that the package manager cache is updated if it hasn't been updated in the last 24 hours.
# This defined type supports Debian-based systems (using apt-get) and RedHat-based systems (using yum or dnf).
#
# Parameters:
#   None
#
# Example Usage:
#
#   To ensure the package manager cache is updated:
#
#     platform::utils::update_package_manager { 'update_package_manager': }
#
# Note:
#   This defined type does not install or manage specific packages. It only updates the package manager cache.
#   It's designed to be used in environments where regular updates of the package manager cache are required
#   to ensure that package installations and upgrades work with the most recent package metadata.
define platform::utils::update_package_manager {
  case $facts['os']['family'] {
    'Debian': {
      exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
        unless  => '/usr/bin/test $(/usr/bin/find /var/cache/apt/pkgcache.bin -mtime -1 | wc -l) -ge 1',
        path    => ['/bin', '/usr/bin'],
      }
    }
    'RedHat': {
      $pkg_manager_cmd = $facts['os']['name'] ? {
        'Fedora' => 'dnf',
        default  => 'yum',
      }
      exec { "${pkg_manager_cmd} makecache":
        command => "/usr/bin/${pkg_manager_cmd} makecache",
        unless  => "/usr/bin/test $(/usr/bin/find /var/cache/${pkg_manager_cmd} -name 'repomd.xml' -mtime -1 | wc -l) -ge 1",
        path    => ['/bin', '/usr/bin'],
      }
    }
    default: {
      warning("The platform::utils::update_package_manager defined type does not support the ${facts['os']['family']} family.")
    }
  }
}
