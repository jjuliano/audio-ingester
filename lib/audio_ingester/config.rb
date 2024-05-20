require 'config'
require 'marcel'

module AudioIngester
  class Configuration
    def initialize(config_file, media_file)
      @config_file = config_file
      @media_file = media_file
    end

    def metadata
      mime_type = Marcel::MimeType.for(@media_file)

      if allowed_mime_types.include? mime_type
        {
          type: mime_type,
          headers: allowed_headers[mime_type],
          schema: schema_validators[mime_type],
        }
      end
    end

    private

    attr_reader :allowed_headers, :allowed_mime_types, :schema_validators

    def config
      Config.load_and_set_settings(@config_file.to_path)
    end

    def allowed_mime_types
      config.AudioIngester.AllowedMusicMimeTypes
    end

    def allowed_headers
      config.AudioIngester.FileHeaders
    end

    def schema_validators
      config.AudioIngester.SchemaValidators
    end
  end
end
