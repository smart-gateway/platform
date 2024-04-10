Facter.add('domain_online_status') do
  setcode do
    domain_name = Facter::Core::Execution.execute('sssctl domain-list', :on_fail => :fail).strip
    if domain_name.empty?
      'unknown'
    else
      status_output = Facter::Core::Execution.execute("sssctl domain-list #{domain_name} --online", :on_fail => :fail)
      if status_output.include?(': Online')
        'online'
      elsif status_output.include?(': Offline')
        'offline'
      else
        'unknown'
      end.downcase
    end
  end
end
