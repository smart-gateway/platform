# frozen_string_literal: true

Facter.add(:home_directories) do
  setcode do
    Facter.debug('Determining home directories')
    if Facter.value(:os)['family'] == 'windows'
      base_dir = 'C:/Users'
    else
      base_dir = '/home'
    end
    Facter.debug("Base directory: #{base_dir}")
    directories = Dir.entries(base_dir).select { |entry|
      File.directory?(File.join(base_dir, entry)) && !(entry == '.' || entry == '..')
    }.map { |entry| "#{base_dir}/#{entry}" }
    Facter.debug("Directories found: #{directories}")
    directories
  end
end
