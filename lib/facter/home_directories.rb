# frozen_string_literal: true

Facter.add(:home_directories) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    Dir.entries('/home').select { |entry|
      File.directory?(File.join('/home', entry)) && !(entry == '.' || entry == '..')
    }
  end
end
