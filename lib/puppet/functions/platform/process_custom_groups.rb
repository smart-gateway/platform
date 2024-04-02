Puppet::Functions.create_function(:'platform::process_custom_groups') do
  dispatch :process_custom_groups do
    param 'Array[Hash]', :custom_entries
    return_type 'Hash'
  end

  def process_custom_groups(custom_entries)
    result = {}

    custom_entries.each do |entry|
      system_value = entry['system'] # Keeping the case as in the original

      admins_key = "Admins-#{system_value}"
      users_key = "Users-#{system_value}"

      # Adding to the result hash
      result[admins_key] = entry['admins']
      result[users_key] = entry['users']
    end

    result
  end
end
