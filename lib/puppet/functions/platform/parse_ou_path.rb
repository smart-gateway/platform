Puppet::Functions.create_function(:'platform::parse_ou_path') do
  dispatch :parse_ou_path do
    param 'String', :ou_string
    return_type 'Array[Hash]'
  end

  def parse_ou_path(ou_string)
    # Initial split on ',OU=' might not catch the first OU if there's no leading comma.
    # Split on 'OU=' and then handle the removal of empty or undesired elements.
    components = ou_string.split(/OU=/).reject(&:empty?)

    path_accumulator = []
    current_path = ''

    components.each do |component|
      # For each component, strip leading and trailing whitespace, just in case.
      sanitized_component = component.strip

      # The DN for the current OU component
      current_dn = if current_path.empty?
                     "OU=#{sanitized_component}"
                   else
                     "OU=#{sanitized_component},#{current_path}"
                   end

      # Append info to the accumulator unless it's the last element, which represents the base DN rather than an OU
      path_accumulator << { 'name' => sanitized_component, 'path' => current_path } unless sanitized_component == components.last

      # Update current_path for the next iteration
      current_path = current_dn
    end

    path_accumulator
  end
end