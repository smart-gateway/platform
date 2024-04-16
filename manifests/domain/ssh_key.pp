# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::domain::ssh_key { 'namevar': }
define platform::domain::ssh_key (
  String[1] $user,
  String[1] $key,
) {
  exec { "add ${key} to user ${user}":
    command   => "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"Import-Module ActiveDirectory; If (-not (Get-ADUser -Filter { SamAccountName -eq '${user}' } -Properties sshPublicKey).sshPublicKey -contains '${key}') { Set-ADUser -Identity '${user}' -Add @{sshPublicKey=@('${key}')} }\"",
    path      => ['C:\Windows\System32', 'C:\Windows', 'C:\Windows\System32\WindowsPowerShell\v1.0'],
    unless    => "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"If ((Get-ADUser -Filter { SamAccountName -eq '${user}' } -Properties sshPublicKey).sshPublicKey -contains '${key}') { exit 0 } else { exit 1 }\"",
    logoutput => false,
  }
}
