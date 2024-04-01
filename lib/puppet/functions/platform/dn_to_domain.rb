Puppet::Functions.create_function(:'platform::dn_to_domain') do
  dispatch :convert do
    param 'String', :dn
    return_type 'String'
  end

  def convert(dn)
    # Split the DN on ',', then on '=' and collect the domain parts
    parts = dn.split(',').map { |x| x.split('=')[1] }
    # Join the parts with '.' to form the domain name
    parts.join('.')
  end
end