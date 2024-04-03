Facter.add('sudo_role_objects') do
  confine :kernel => 'windows'  # Ensure this fact only runs on Windows systems

  setcode do
    require 'win32/registry'
    objects = []

    # Check if the system is a Domain Controller
    is_dc = false
    begin
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SYSTEM\CurrentControlSet\Services\NTDS\Parameters') do |reg|
        is_dc = true
      end
    rescue
      is_dc = false
    end
    Facter.debug("is_dc evaluated to : #{is_dc}")

    if is_dc
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
      result = Facter::Core::Execution.execute("powershell -command #{ps_script}", :timeout => 30)
      Facter.debug("result of execution was: #{result}")

      # Split the output into an array of names, unless it's empty
      objects = result.split("\r\n").reject(&:empty?) unless result.nil? || result.empty?
    end

    objects
  end
end
