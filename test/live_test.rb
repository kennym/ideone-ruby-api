# frozen_string_literal: true

require "test_helper"

class LiveTest < Minitest::Test
  def setup
    skip "Set IDEONE_USER and IDEONE_PASSWORD to run live API tests" unless live?
    WebMock.allow_net_connect!
    @client = Ideone::Client.new(ENV.fetch("IDEONE_USER"), ENV.fetch("IDEONE_PASSWORD"))
  end

  def teardown
    WebMock.disable_net_connect!
  end

  def test_test_function
    result = @client.test
    assert_equal "OK", result["error"]
    assert_equal "42", result["answerToLifeAndEverything"].to_s
  end

  def test_languages_include_ruby
    result = @client.languages
    assert_operator result.size, :>, 10
    assert_match(/Ruby/i, result["17"].to_s)
  end

  def test_submission_status_for_known_link
    result = @client.submission_status("PD2kqM")
    assert_equal 0, result[:status]
    assert_equal 15, result[:result]
  end

  private

  def live?
    !ENV["IDEONE_USER"].to_s.empty? && !ENV["IDEONE_PASSWORD"].to_s.empty?
  end
end
