# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::utils::mark_applied { 'namevar': }
define platform::utils::mark_applied (
  String $class_name = $title
) {
  $filename = $facts['os']['family'] ? {
    'windows' => "C:/Temp/puppet-agent/applied/${class_name}",
    default   => "/tmp/puppet-agent/applied/${class_name}"
  }

  $owner = $facts['os']['family'] ? {
    'windows' => 'Administrator',
    default   => 'root'
  }

  $group = $facts['os']['family'] ? {
    'windows' => 'Administrators',
    default   => 'root'
  }

  file { $filename:
    ensure  => file,
    mode    => '0444',
    owner   => $owner,
    group   => $group,
    content => "${class_name} applied",
  }
}
