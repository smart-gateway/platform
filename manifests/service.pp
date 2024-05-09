# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::service
class platform::service {
  platform::utils::manage_service { 'platform_exporter':
    ensure => $platform::ensure_platform_exporter,
    binary => $platform::platform_exporter_binary_location,
    tag    => ['tools', 'service', 'puppet'],
  }
}
