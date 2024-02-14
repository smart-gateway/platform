# Define a new type in platform/manifests/manage_service.pp
define platform::utils::manage_service (
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure = 'running',
  Optional[Array[File]] $require_files = undef,
  Optional[String] $binary = undef,
) {
  $actual_ensure = $ensure ? {
    Pattern[/^(yes|present|installed)$/ ] => 'running',
    default                               => 'stopped',
  }

  $actual_enable = $ensure ? {
    Pattern[/^(yes|present|installed)$/ ] => true,
    default                               => false,
  }

  $is_docker = $facts['virtual'] ? { 'docker' => true, default => false }
  if !$is_docker {
    # Manage the service
    service { $title:
      ensure    => $actual_ensure,
      enable    => $actual_enable,
      require   => $require_files,
      binary    => $binary,
    }
  } else {
    notify {"The ${title} service cannot be managed on docker.": }
  }

}
