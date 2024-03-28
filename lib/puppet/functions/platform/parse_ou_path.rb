Puppet::Functions.create_function(:'platform::parse_ou_path') do
  dispatch :parse_ou_path do
    param 'String', :ou_string
    return_type 'Array[Hash]'
  end

  def parse_ou_path(ou_string)
    # Split the OU string into components and reverse to start from the top-level OU
    components = ou_string.split(/OU=/).reject(&:empty?).reverse
    path_accumulator = []
    current_path = ''

    components.each do |component|
      # For each component, strip leading and trailing whitespace
      sanitized_component = component.strip.gsub(',','')

      # Construct the DN for the current component
      current_dn = if current_path.empty?
                     "OU=#{sanitized_component}"
                   else
                     "OU=#{sanitized_component},#{current_path}"
                   end

      # Append the current component and path to the accumulator
      path_accumulator << { 'name' => sanitized_component, 'path' => current_path }

      # Update current_path for the next iteration
      current_path = current_dn
    end

    path_accumulator
  end

end
