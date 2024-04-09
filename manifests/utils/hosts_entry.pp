# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::utils::hosts_entry { 'namevar': }
define platform::utils::hosts_entry (
  Enum['present', 'absent'] $ensure = 'present',
  String $name = $title,
  String $ip,
  Optional[String] $aliases = undef,
  Optional[String] $comment = undef,
) {
  $target = $facts['kernel'] ? {
    'Linux' => '/etc/hosts',
    'Windows' => 'C:/Windows/System32/drivers/etc/hosts',
    default => undef,
  }

  host { $name:
    ensure  => $ensure,
    ip      => $ip,
    target  => $target,
    aliases => $aliases,
    comment => $comment,
  }
}
