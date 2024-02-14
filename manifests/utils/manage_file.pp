define platform::utils::manage_file (
  Enum['yes', 'present', 'installed', 'no', 'absent', 'uninstalled'] $ensure,
  String $source,
  String $path,
  String $mode = '0755',
  String $owner = 'root',
  String $group = 'root',
) {
  $actual_state = $ensure ? {
    Pattern[/^(yes|present|installed)$/ ] => 'file',
    default                               => 'absent',
  }

  file { $title:
    ensure => $actual_state,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
    source => $source,
    path   => $path,
  }
}
