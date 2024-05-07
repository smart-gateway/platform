# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include platform::utils::cleanup
class platform::utils::cleanup {
  # Ensure old reports are cleaned up
  tidy { '/opt/puppetlabs/puppet/cache/reports':
    age     => '1w',
    recurse => true,
  }

  tidy { '/opt/puppetlabs/server/data/puppetserver/reports':
    age     => '1w',
    recurse => true,
  }
}
