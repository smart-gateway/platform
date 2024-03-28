Puppet::Functions.create_function(:'platform::parse_ou_path') do
  dispatch :parse_ou_path do
    param 'String', :ou_string
    return_type 'Array[Hash]'
  end

  def parse_ou_path(ou_string)
    # Split the OU string into components and reverse to start from the top-level OU
    components = ou_string.split(/,OU=/).reverse
    path_accumulator = []

    components.reduce('') do |acc, component|
      # Construct the DN for the current component
      current_dn = "OU=#{component},#{acc}".chomp(',')
      # Append the current component and path to the accumulator
      path_accumulator << { 'name' => component, 'path' => acc }
      # Update the accumulator with the current DN
      current_dn
    end

    path_accumulator
  end
end
