# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::utils::import_ssh_keys { 'namevar': }
define platform::utils::import_ssh_keys (
  String $id,
  String $user,
  String $authorized_keys_path,
) {
  # The comment to be added to the authorized_keys file
  $comment = "# imported ${id}"

  # Exec resource to import the SSH key
  exec { "import-ssh-key-${id}":
    command => "/usr/bin/ssh-import-id ${id}",
    unless  => "/bin/grep -Fxq '${comment}' ${authorized_keys_path}",
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    user    => $user,
  }

  # File_line resource to manage the comment in the authorized_keys file
  file_line { "comment-for-${id}":
    path    => $authorized_keys_path,
    line    => $comment,
    after   => "import-ssh-key-${id}",
    match   => "^# imported ${id}\$",
    require => Exec["import-ssh-key-${id}"],
  }
}
