# frozen_string_literal: true

Facter.add(:home_directories) do
  setcode do
    if Facter.value(:os)['family'] == 'windows'
      base_dir = 'C:/Users'
    else
      base_dir = '/home'
    end
    Dir.entries(base_dir).select { |entry|
      File.directory?(File.join(base_dir, entry)) && !(entry == '.' || entry == '..')
    }.map { |entry| "#{base_dir}/#{entry}" }
  end
end
