# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::service
class platform::service {

  $puppet_exporter_file = File['platform::puppet_exporter_file']
  platform::utils::manage_service { 'puppet_agent_exporter':
    ensure        => $::platform::ensure_puppet_exporter,
    require_files => [$puppet_exporter_file],
  }

}
