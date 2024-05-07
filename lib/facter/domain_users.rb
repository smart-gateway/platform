Facter.add('domain_users') do
  confine :kernel => 'windows'  # This fact will only run on Windows systems
  setcode do
    if Facter.value(:is_domain_controller)
      powershell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
      command = <<-EOS
        Import-Module ActiveDirectory
        $users = Get-ADUser -Filter * -Property SamAccountName | Select-Object -ExpandProperty SamAccountName
        $users -join ','
      EOS
      result = Facter::Core::Execution.execute("#{powershell} -Command \"#{command}\"", :timeout => 30)
      if result.empty?
        nil
      else
        result.split(',')  # Split the result into an array
      end
    else
      nil
    end
  end
end