# Defined Type: platform::package
#
# This defined type is a wrapper around the stdlib::ensure_packages function, allowing for
# the declaration of package resources within the platform module with a simplified interface.
# It ensures that the specified package is in the desired state, abstracting away the details
# of package management.
#
# Parameters:
#   - ensure: Specifies the desired package state, such as 'present', 'absent', 'latest', or a specific version.
#
# Example Usage:
#
#   To ensure a package is installed:
#     platform::packages::package { 'nginx':
#       ensure => 'present',
#     }
#
#   To remove a package:
#     platform::packages::package { 'apache2':
#       ensure => 'absent',
#     }
#
#   To ensure a package is updated to the latest version:
#     platform::packages::package { 'curl':
#       ensure => 'latest',
#     }
#
define platform::packages::package (
  Enum['present', 'absent', 'installed', 'latest', 'held', 'purged'] $ensure,
  Optional[String] $package_name = $title
) {
  # Check if a Package resource with this title or name already exists
  if ! defined(Package[$title]) and ! defined(Package[$package_name]) {
    package { $title:
      ensure => $ensure,
      name   => $package_name,
    }
  } else {
    notify { "Package ${title} is already declared in the catalog; Skipping declaration in platform::packages::package":
      loglevel => 'debug',
    }
  }
}

# Class: platform::packages
#
# This class manages multiple packages based on a hash of package names and their desired states.
# It leverages the create_resources function to dynamically declare platform::package resources
# from a hash, allowing for the bulk management of package resources within the platform module.
#
# The package data should be provided through Hiera or an external data source, associating
# each package name with its desired state.
#
# Example Hiera data:
#   platform::packages:
#     'git':
#       ensure: 'latest'
#     'tree':
#       ensure: 'present'
#     'vim':
#       ensure: 'purged'
#
# Note:
#   The platform::packages class checks if the $::platform::packages variable is defined
#   and not undef before attempting to create resources, ensuring that package management
#   is only attempted when package data is provided.
#
#   Allowed values:
#     present
#     absent
#     purged
#     disabled
#     installed
#     latest
#     /./ (any specific version)
class platform::packages {
  if $platform::packages != undef {
    create_resources(platform::packages::package, $platform::packages)
  }
}
