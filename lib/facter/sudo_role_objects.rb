Facter.add('sudo_role_objects') do
  confine :kernel => 'windows'  # Ensure this fact only runs on Windows systems

  setcode do
    objects = []

    # Check if the system is a Domain Controller
    is_dc = Facter::Core::Execution.execute('powershell -command "(Get-ADDomainController -ErrorAction SilentlyContinue) -ne $null"')
    if is_dc.strip == 'True'
      # PowerShell script to find sudoRole objects
      ps_script = <<-PS
        try {
          Import-Module ActiveDirectory -ErrorAction Stop
          $objects = Get-ADObject -Filter 'objectClass -eq "sudoRole"' -Properties * -ErrorAction Stop
          $objects | ForEach-Object { $_.Name }
        } catch {
          # In case of error, return an empty array
          Write-Output ""
        }
      PS

      # Run the PowerShell script and capture the output
      result = Facter::Core::Execution.execute("powershell -command \"#{ps_script}\"", :timeout => 30)

      # Split the output into an array of names, unless it's empty
      objects = result.split("\n").reject(&:empty?) unless result.nil? || result.empty?
    end

    objects
  end
end
