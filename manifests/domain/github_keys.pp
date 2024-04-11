# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   platform::domain::github_keys { 'namevar': }
define platform::domain::github_keys (
  String[1] $user,
  String[1] $github_username,
) {
  # This defined type uses a PowerShell script stored at a specific location
  # Ensure the PowerShell script is accessible on the system where this defined type is applied
  exec { "import GitHub SSH keys from ${github_username} to user ${user}":
    command   => "powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\\ProgramData\\PuppetLab\\Import-GitHubSSHKeysToUser.ps1' -User '${user}' -GitHubUsername '${github_username}'",
    path      => ['C:\Windows\System32', 'C:\Windows', 'C:\Windows\System32\WindowsPowerShell\v1.0'],
    logoutput => true,
  }
}
