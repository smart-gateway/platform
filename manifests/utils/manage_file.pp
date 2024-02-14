define platform::utils::manage_file (
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure,
  String $source,
  String $path,
) {
  $actual_state = $ensure ? {
    Pattern[/^(yes|present|installed)$/ ] => 'file',
    default                               => 'absent',
  }

  file { $title:
    ensure => $actual_state,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => $source,
    path   => $path,
  }
}
