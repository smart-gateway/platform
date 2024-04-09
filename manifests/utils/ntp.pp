# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::utils::ntp
class platform::utils::ntp (
  Array[String] $ntp_servers,
  Array[String] $fallback_ntp_servers = ['ntp.ubuntu.com'],
  String $root_distance_max_sec = '43200',
  String $poll_interval_min_sec = '32',
  String $poll_interval_max_sec = '2048',
) {
  # Ensure that the ntp package is not installed
  platform::packages::package { 'platform::utils::ntp:ensure_ntp_not_installed':
    ensure       => absent,
    package_name => 'ntp',
  }

  # Ensure that the systemd-timesyncd package is installed
  ->platform::packages::package { 'platform::utils::ntp:ensure_systemd-timesyncd_installed':
    ensure       => present,
    package_name => 'systemd-timesyncd',
  }

  # Create the configuration file
  ->file { '/etc/systemd/timesyncd.conf':
    ensure  => file,
    content => epp('platform/ntp/etc/systemd/timesyncd.conf.epp', {
        ntp_servers           => $ntp_servers,
        fallback_ntp_servers  => $fallback_ntp_servers,
        root_distance_max_sec => $root_distance_max_sec,
        poll_interval_min_sec => $poll_interval_min_sec,
        poll_interval_max_sec => $poll_interval_max_sec,
    }),
    notify  => Service['systemd-timesyncd'],
  }

  # Restart the systemd-timesyncd service if the configuration file changes
  ~>service { 'systemd-timesyncd':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/systemd/timesyncd.conf'],
  }
}
