Facter.add('joined_to_domain') do
  setcode do
    if Facter.value(:kernel) == 'windows'
      # Placeholder for Windows implementation
      false
    else
      output = Facter::Core::Execution.execute('realm list 2>/dev/null', :timeout => 5)
      !output.empty?
    end
  end
end