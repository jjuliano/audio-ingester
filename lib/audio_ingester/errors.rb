module AudioIngester
  module Errors
    FatalException = Class.new(::RuntimeError)

    FileFormatError = Class.new(FatalException)
    UnsupportedFileError = Class.new(FatalException)
    UnknownExceptionError = Class.new(FatalException)
    ValidationFailedError = Class.new(FatalException)
  end
end
