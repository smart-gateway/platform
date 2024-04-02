Puppet::Functions.create_function(:'platform::format_members') do
  dispatch :format_members do
    param 'Array[String]', :members
    param 'String', :path
    return_type 'Array[String]'
  end

  def format_members(members, path)
    members.map { |member| "CN=#{member},#{path}" }
  end
end
