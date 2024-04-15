Puppet::Functions.create_function(:'platform::process_custom_groups') do
  dispatch :process_custom_groups do
    param 'Array[Hash]', :custom_entries
    return_type 'Hash'
  end

  def process_custom_groups(custom_entries)
    result = {}

    custom_entries.each do |entry|
      system_value = entry['system']  # Keeping the case as in the original

      admins_key = "Admins-#{system_value}"
      users_key = "Users-#{system_value}"

      # Sort the members arrays before adding them to the result hash
      sorted_admins = entry['admins'].sort
      sorted_users = entry['users'].sort

      # Adding sorted lists to the result hash
      result[admins_key] = sorted_admins
      result[users_key] = sorted_users
    end

    result
  end
end
