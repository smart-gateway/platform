# Define a new type in platform/manifests/manage_service.pp
define platform::manage_service (
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure = 'running',
  Optional[Array[File]] $require_files = undef,
) {
  $actual_ensure = $ensure ? {
    Pattern[/^(yes|present|installed)$/ ] => 'running',
    default                               => 'stopped',
  }

  $actual_enable = $ensure ? {
    Pattern[/^(yes|present|installed)$/ ] => true,
    default                               => false,
  }

  # Manage the service
  service { $title:
    ensure    => $actual_ensure,
    enable    => $actual_enable,
    require   => $require_files,
  }
}
