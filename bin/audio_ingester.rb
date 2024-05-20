#!/usr/bin/env ruby

require 'thor'
require 'nokogiri'
require 'logger'
require 'find'
require_relative '../lib/boot'

module AudioIngester
  CONFIG_FILE = "../config/config.yml".freeze
  SCHEMA_DIR = "../data/schema".freeze
  BASE_DIR = "output".freeze
  LOG_LEVEL = Logger::INFO

  class CLI < Thor
    include AudioIngester::Utils::Output

    map ["-v", "--version"] => :version
    desc "--version, -v", "Display version"
    def version
      puts VERSION::STRING
    end

    option :config, type: :string, desc: "Path to the config file. Defaults to #{CONFIG_FILE}."
    option :schema, type: :string, desc: "Path to the schema file."
    option :output, type: :string, desc: "Specify the output path. Defaults to '#{BASE_DIR}'."
    option :skip_validation, type: :boolean, desc: "Skip the schema validation."

    desc 'parse FILE or DIR', 'Parse the metadata of an audio FILE or a DIR that contains one or more audio files'
    def parse(target)
      logger = Logger.new(STDOUT)
      logger.level = LOG_LEVEL
      targets = []

      if File.directory?(target)
        targets = Find.find(target).select(&File.method(:file?))
      else
        targets << target
      end

      targets.each do |file|
        io = File.new(file, 'rb')

        config_file = options[:config_file] || CONFIG_FILE
        config = Configuration.new(File.open(File.join(File.dirname(__FILE__), "#{config_file}")), io)

        logger.debug "File config"
        logger.debug config

        begin
          unless config.metadata.nil?
            track_data = {}

            mime_type = config.metadata[:type]
            logger.info "File '#{file}' with mime-type '#{mime_type}' detected!"
            config.metadata[:headers].each do |m|
              #
              # Dynamically extend module based on header methods.
              #
              # i.e. WavFile#bit_rate vs. Mp3File#bit_rate has different implementations
              #
              metadata = Metadata.dup

              case mime_type
              when "audio/x-wav"
                metadata.extend Metadata::WavFile
              end

              metadata.instance_variable_set("@io", io)
              metadata.instance_variable_set("@header", metadata.get_wav_header)

              track_data[m.to_sym] = metadata.send(m.to_sym)
            end

            logger.info "Building XML..."
            builder = Nokogiri::XML::Builder.new do |xml|
              xml.track {
                track_data.each do |key, value|
                  logger.debug "#{key}: #{value}"
                  if track_data.keys[0] == key
                    xml.format track_data[key] # Append first the element index 0
                  else
                    xml.send(key, value)
                  end
                end
              }
            end

            xml_output = builder.to_xml

            unless options[:skip_validation]
              logger.info "Validating XML..."
              schema_file = options[:schema] || "#{SCHEMA_DIR}/#{config.metadata[:schema]}"

              xsd = Nokogiri::XML::Schema(File.open(File.join(File.dirname(__FILE__), "#{schema_file}")))
              doc = Nokogiri::XML(xml_output)

              errors = xsd.validate(doc)

              if errors.empty?
                logger.info "XML is valid."
              else
                begin
                  logger.error "XML is invalid."

                  errors.each do |error|
                    logger.error error.message
                  end

                  raise AudioIngester::Errors::ValidationFailedError.new("ERROR: Validation Failed.")
                rescue Exception => e
                  logger.error e.message
                  e.backtrace.each { |line| logger.error line }
                end
              end
            end

            base_dir = options[:output] || BASE_DIR
            print_metadata(file, track_data, mime_type)

            save_file(logger, file, base_dir, xml_output)

            io.close
          else
            raise AudioIngester::Errors::UnsupportedFileError.new("ERROR: File #{file} is unsupported!")
          end
        rescue Exception => e
          logger.error e.message
          e.backtrace.each { |line| logger.error line }
        end
      end
    end
  end
end

AudioIngester::CLI.start(ARGV)
