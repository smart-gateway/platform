Facter.add('domain_info') do
  setcode do
    if Facter.value(:kernel) == 'windows'
      # Placeholder for Windows implementation
      {}
    else
      realm_hash = {}
      output = Facter::Core::Execution.execute('realm list 2>/dev/null', :timeout => 5)
      unless output.empty?
        current_domain = ''
        output.each_line do |line|
          if line =~ /^\S/
            current_domain = line.strip
            realm_hash[current_domain] = {}
          elsif line =~ /^\s+(\S+):\s*(.*)$/
            key, value = line.strip.split(': ', 2)
            if key == 'required-package'
              realm_hash[current_domain][key] ||= []
              realm_hash[current_domain][key] << value
            else
              realm_hash[current_domain][key] = value
            end
          end
        end
      end
      realm_hash
    end
  end
end
