Puppet::Functions.create_function(:'platform::process_custom_groups') do
  dispatch :process_custom_groups do
    param 'Array[Hash]', :custom_entries
    return_type 'Hash'
  end

  def process_custom_groups(custom_entries)
    result = {}

    custom_entries.each do |entry|
      system_value = entry['system'] # Keeping the case as in the original
      admins_key = "admins-#{system_value.downcase}"
      users_key = "users-#{system_value.downcase}"

      admins_value = "Admins-#{system_value}"
      users_value = "Users-#{system_value}"

      # Adding to the result hash
      result[admins_key] = admins_value
      result[users_key] = users_value
    end

    result
  end
end
