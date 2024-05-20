module AudioIngester
  module Utils
    module Output
      def directory(base_dir)
        "#{base_dir}/#{Time.now.to_i}"
      end

      def padding
        "\n" + "-" * 47
      end

      def print_metadata(file, track_data, mime_type)
        printout = "\n"
        printout += "  File: #{file}\n"
        printout += "  Mime Type: #{mime_type}\n"
        track_data.each do |key, value|
          title = key.to_s.split('_').collect(&:capitalize).join(" ")
          printout += "  #{title}: #{value}\n"
        end
        printout += "\n"
        puts printout
      end

      def save_file(logger, file, base_dir, xml_output)
        logger.debug "Saving XML #{file}..."

        # 1. Create the parent base dir first. Do this only once.
        Dir.mkdir(base_dir) unless Dir.exists?(base_dir)

        # 2. Optimistically create the directory.
        # Check the folder first if it exists.
        # If the folder exists, regenerate a new timestamp.
        timestamped_folder = directory(base_dir)
        if Dir.exists?(timestamped_folder)
          logger.warn "FOLDER #{timestamped_folder} exists. Regenerating new timestamp after 2 seconds."
          # RACE CONDITION FIX: We regen timestamp after a time period
          sleep 2
          timestamped_folder = directory(base_dir)
        end

        logger.info "Creating directory '#{timestamped_folder}'..."
        while(!Dir.exists?(timestamped_folder)) do
          Dir.mkdir(timestamped_folder)
        end

        filename = File.basename(file, File.extname(file))

        logger.info "Saving Metadata XML file '#{timestamped_folder}/#{filename}.xml'" + padding
        File.write("#{timestamped_folder}/#{filename}.xml", xml_output)
      end
    end
  end
end
