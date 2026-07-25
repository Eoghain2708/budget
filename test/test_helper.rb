require "minitest/autorun"
require_relative "support/fakes"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "budget"

class Minitest::Test
  include TestFactories
end