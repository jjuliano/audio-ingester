Dir[File.join(File.dirname(__FILE__), 'metadata/**/*.rb')].each { |headers| require_relative headers }

#
# This module is required for dynamically
# extending the module based on header methods
# for other media types
#
module AudioIngester
  module Metadata
    extend Utils::Headers
  end
end
