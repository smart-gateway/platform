Facter.add('is_domain_controller') do
  confine :kernel => :windows
  setcode do
    require 'win32/registry'

    is_dc = false
    begin
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SYSTEM\CurrentControlSet\Services\NTDS\Parameters') do |reg|
        is_dc = true
      end
    rescue
      is_dc = false
    end

    is_dc
  end
end
