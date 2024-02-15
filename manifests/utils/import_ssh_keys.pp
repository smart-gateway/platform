# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::utils::import_ssh_keys { 'namevar': }
define platform::utils::import_ssh_keys (
  String $id,
  String $user,
) {
  # Define the path to the authorized_keys file
  $authorized_keys_path = "/home/${user}/.ssh/authorized_keys"

  # The comment to be added to the authorized_keys file
  $comment = "# imported ${id}"

  # Exec resource to import the SSH key
  exec { "import-ssh-key-${id}":
    command => "/usr/bin/ssh-import-id ${id}",
    unless  => "/bin/grep -Fxq '${comment}' ${authorized_keys_path}",
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    user    => $user,
    require => File[$authorized_keys_file_resource_title],
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
