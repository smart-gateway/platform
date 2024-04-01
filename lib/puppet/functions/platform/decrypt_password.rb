require 'openssl'
require 'base64'

Puppet::Functions.create_function(:'platform::decrypt_password') do
  dispatch :decrypt_password do
    param 'String', :base64_private_key
    param 'String', :base64_encrypted_password
    return_type 'String'
  end

  def decrypt_password(base64_private_key, base64_encrypted_password)
    # Decode the Base64 encoded private key and encrypted password
    private_key_data = Base64.strict_decode64(base64_private_key)
    encrypted_password_data = Base64.strict_decode64(base64_encrypted_password)

    # Load the private RSA key
    private_key = OpenSSL::PKey::RSA.new(private_key_data)

    # Decrypt the password
    decrypted_password = private_key.private_decrypt(encrypted_password_data)

    # Return the decrypted password as a string
    decrypted_password
  end
end
