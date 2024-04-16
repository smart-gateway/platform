Puppet::Functions.create_function(:'platform::process_custom_groups') do
  dispatch :process_custom_groups do
    param 'Array[Hash]', :custom_entries
    param 'String', :users_path
    param 'String', :groups_path
    return_type 'Hash'
  end

  def process_custom_groups(custom_entries, users_path, groups_path)
    result = {}

    custom_entries.each do |entry|
      system_value = entry['system']  # Keeping the case as in the original

      # Construct group DN for the admins
      admins_key = "Admins-#{system_value}"
      admins_dn = "CN=#{admins_key},#{groups_path}"

      # Construct group DN for the users
      users_key = "Users-#{system_value}"
      users_dn = "CN=#{users_key},#{users_path}"

      # Prepare the admin group DN to add to users
      admin_group_dn = "CN=#{admins_key},#{groups_path}"

      # Add the admin group DN to the users array and ensure all are DNs
      combined_users = entry['users'].map { |user| "CN=#{user},#{users_path}" }
      combined_users << admin_group_dn unless combined_users.include?(admin_group_dn) # Prevent duplicates

      # Sort the members arrays before adding them to the result hash
      sorted_admins = entry['admins'].map { |admin| "CN=#{admin},#{groups_path}" }.sort
      sorted_users = combined_users.sort

      # Adding sorted lists to the result hash with DNs
      result[admins_dn] = sorted_admins
      result[users_dn] = sorted_users
    end

    result
  end
end
