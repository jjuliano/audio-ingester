require "rubygems"

require_relative "version"

Dir[File.join(File.dirname(__FILE__), '**/**/*.rb')].reverse.each { |x| require x }
