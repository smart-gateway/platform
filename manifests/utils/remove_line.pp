define platform::utils::remove_line (
  String $filename,
  String $line,
  String $match,
) {
  # Check if the file exists
  exec { "check_${filename}_exists":
    command     => '/bin/true',
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    onlyif      => "test -f ${filename}",
    refreshonly => true,
  }

  # Remove the specified line from the file if it exists
  exec { "remove_${line}_from_${filename}":
    command     => "sed -i '/${line}/d' ${filename}",
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    onlyif      => "grep -q '${match}' ${filename}",
    subscribe   => Exec["check_${filename}_exists"],
    refreshonly => true,
  }
}
