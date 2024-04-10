Facter.add('domain_name') do
  setcode do
    domain_name = Facter::Core::Execution.execute('sssctl domain-list', :on_fail => :fail)
    domain_name.strip
  end
end
