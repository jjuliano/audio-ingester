# AudioIngester

AudioIngester is a command-line tool for parsing and processing metadata from audio files. It validates the metadata against XML schemas and saves the output in a specified directory.

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Prerequisites

- Ruby (version 2.7 or later)
- Bundler

### Setup

1. Clone the repository:

    ```sh
    git clone https://github.com/jjuliano/audio-ingester.git
    cd audio-ingester
    ```

2. Install the dependencies:

    ```sh
    bundle install
    ```

## Configuration

The configuration file is located at `config/config.yml`. This file specifies the allowed MIME types, file headers, and schema validators for different audio formats. An example configuration is shown below:

```yaml
AudioIngester:
  AllowedMusicMimeTypes:
    - "audio/x-wav"
  FileHeaders:
    "audio/x-wav":
      - format
      - channel_count
      - sampling_rate
      - bit_depth
      - byte_rate
      - bit_rate
  SchemaValidators:
    "audio/x-wav": wav.xsd
```

## Usage

The `audio_ingester` command provides functionality for parsing and validating audio file metadata.

### Parsing a File

To parse a single audio file, use the `parse` command:

```sh
./bin/audio_ingester.rb parse path/to/your/file.wav
```

### Options

- `--config`: Path to the configuration file. Defaults to `config/config.yml`.
- `--schema`: Path to the schema file.
- `--output`: Specify the output path. Defaults to `output`.
- `--skip_validation`: Skip the schema validation.

### Example

```sh
./bin/audio_ingester.rb parse --config=config/custom_config.yml --schema=data/schema/custom_schema.xsd --output=custom_output --skip_validation path/to/your/file.wav
```

## Development

### Running Tests

To run the tests, use the following command:

```sh
rake test
```

### Code Structure

- `lib/audio_ingester/config.rb`: Handles configuration loading and metadata extraction.
- `lib/audio_ingester/utils/output.rb`: Contains utility methods for output directory management and file saving.
- `lib/audio_ingester/utils/headers.rb`: Contains utility for file header probing and extraction from audio files.
- `lib/audio_ingester/metadata.rb`: Handles metadata extraction from audio files using header extraction methods specified in the files within the `/lib/audio_ingester/metadata/` directory.
- `lib/audio_ingester/errors.rb`: Defines custom error classes.
- `bin/audio_ingester.rb`: The main CLI tool.

### Logging

The tool uses the standard Ruby `Logger` for logging information, warnings, and errors.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

1. Fork the repository.
2. Create a new branch (`git checkout -b my-feature-branch`).
3. Make your changes and commit them (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-feature-branch`).
5. Create a new Pull Request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
