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
  file { 'C:\\ProgramData\\PuppetLabs\\Import-GitHubSSHKeysToUser.ps1':
    ensure  => file,
    content => epp('platform/domain/programdata/puppetlabs/Import-GitHubSSHKeysToUser.ps1.epp'),
  }

  schedule { 'every_6_hours':
    period => 'daily',
    repeat => 4, # 24 hours / 6 = 4 times a day
    range  => '00:00 - 23:59', # Whole day
  }

  # This defined type uses a PowerShell script stored at a specific location
  # Ensure the PowerShell script is accessible on the system where this defined type is applied
  exec { "import GitHub SSH keys from ${github_username} to user ${user}":
    command   => "powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\ProgramData\PuppetLabs\Import-GitHubSSHKeysToUser.ps1' -User '${user}' -GitHubUsername '${github_username}'",
    path      => ['C:\Windows\System32', 'C:\Windows', 'C:\Windows\System32\WindowsPowerShell\v1.0'],
    logoutput => true,
  }
}
