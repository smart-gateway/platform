# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::service
class platform::service {
  if $facts['kernel'] == 'Linux' {
    platform::utils::manage_service { 'puppet_agent_exporter':
      ensure => $platform::ensure_puppet_exporter,
      binary => $platform::puppet_exporter_binary_location,
    }
  }
}
