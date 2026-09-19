# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ideone"
require "minitest/autorun"
require "webmock/minitest"

module FixtureHelper
  def fixture_path(name)
    File.expand_path("fixtures/#{name}", __dir__)
  end

  def fixture(name)
    File.read(fixture_path(name))
  end
end

class Minitest::Test
  include FixtureHelper
end
