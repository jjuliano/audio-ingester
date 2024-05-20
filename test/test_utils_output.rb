require 'minitest/autorun'
require 'mocha/minitest'
require 'fileutils'
require_relative '../lib/audio_ingester/utils/output'

class TestUtilsOutput < Minitest::Test
  include AudioIngester::Utils::Output

  def setup
    @base_dir = "test_dir"
    @logger = mock('Logger')
    @logger.stubs(:debug).returns("Debug!")
    @logger.stubs(:info).returns("Info!")
    FileUtils.mkdir_p(@base_dir)
  end

  def teardown
    FileUtils.rm_rf(@base_dir)
  end

  def test_directory_method
    fixed_time = Time.now.to_i
    Time.stub :now, Time.at(fixed_time) do
      expected_dir = "#{@base_dir}/#{fixed_time}"
      assert_equal expected_dir, directory(@base_dir)
    end
  end

  def test_save_file_creates_base_directory
    fixed_time = Time.now.to_i
    Time.stub :now, Time.at(fixed_time) do
      save_file(@logger, "test_file.xml", @base_dir, "<xml>content</xml>")
    end

    assert Dir.exist?(@base_dir)
  end

  def test_save_file_creates_timestamped_directory
    fixed_time = Time.now.to_i
    Time.stub :now, Time.at(fixed_time) do
      save_file(@logger, "test_file.xml", @base_dir, "<xml>content</xml>")
    end

    expected_timestamped_dir = "#{@base_dir}/#{fixed_time}"
    assert Dir.exist?(expected_timestamped_dir)
  end

  def test_save_file_writes_xml_content
    fixed_time = Time.now.to_i
    Time.stub :now, Time.at(fixed_time) do
      save_file(@logger, "test_file.xml", @base_dir, "<xml>content</xml>")
    end

    expected_timestamped_dir = "#{@base_dir}/#{fixed_time}"
    expected_file = "#{expected_timestamped_dir}/test_file.xml"
    assert File.exist?(expected_file)
    assert_equal "<xml>content</xml>", File.read(expected_file)
  end

  def test_save_file_regenerates_timestamp_if_directory_exists
    fixed_time = Time.now.to_i
    first_timestamped_folder = nil

    Time.stub :now, Time.at(fixed_time) do
      save_file(@logger, "test_file.xml", @base_dir, "<xml>content</xml>")
      first_timestamped_folder = "#{@base_dir}/#{fixed_time}"
    end

    assert Dir.exist?(first_timestamped_folder)

    Time.stub :now, Time.at(fixed_time + 1) do
      save_file(@logger, "test_file.xml", @base_dir, "<xml>new_content</xml>")
    end

    second_timestamped_folder = "#{@base_dir}/#{fixed_time + 1}"
    assert Dir.exist?(second_timestamped_folder)
    assert File.exist?("#{second_timestamped_folder}/test_file.xml")
    assert_equal "<xml>new_content</xml>", File.read("#{second_timestamped_folder}/test_file.xml")
  end
end
