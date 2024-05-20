require 'minitest/autorun'
require 'mocha/minitest'
require 'config'
require 'marcel'
require_relative '../lib/audio_ingester/config'

class TestConfiguration < Minitest::Test
  def setup
    @config_file = mock('File')
    @config_file.stubs(:to_path).returns('test_config.yml')
    @media_file = 'test_media.wav'

    @mock_audio_ingester = mock('AudioIngester::Configuration')
    @mock_audio_ingester.stubs(:AllowedMusicMimeTypes).returns(['audio/x-wav'])
    @mock_audio_ingester.stubs(:FileHeaders).returns({ 'audio/x-wav' => ['format', 'channel_count', 'sampling_rate', 'bit_depth', 'byte_rate', 'bit_rate'] })
    @mock_audio_ingester.stubs(:SchemaValidators).returns({ 'audio/x-wav' => 'wav.xsd' })

    @mock_config = mock('Config')
    @mock_config.stubs(:AudioIngester).returns(@mock_audio_ingester)
    Config.stubs(:load_and_set_settings).returns(@mock_config)

    @configuration = AudioIngester::Configuration.new(@config_file, @media_file)
  end

  def test_metadata_with_allowed_mime_type
    Marcel::MimeType.stubs(:for).with(@media_file).returns('audio/x-wav')

    expected_metadata = {
      type: 'audio/x-wav',
      headers: ['format', 'channel_count', 'sampling_rate', 'bit_depth', 'byte_rate', 'bit_rate'],
      schema: 'wav.xsd'
    }

    assert_equal expected_metadata, @configuration.metadata
  end

  def test_metadata_with_disallowed_mime_type
    Marcel::MimeType.stubs(:for).with(@media_file).returns('video/mp4')

    assert_nil @configuration.metadata
  end
end
