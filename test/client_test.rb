# frozen_string_literal: true

require "test_helper"

class ClientTest < Minitest::Test
  def setup
    WebMock.disable_net_connect!
    @client = Ideone::Client.new("user", "pass", wsdl: fixture_path("wsdl.xml"))
  end

  def test_wsdl_uses_https
    assert_equal "https://ideone.com/api/1/service.wsdl", Ideone::Client::WSDL_URL
  end

  def test_new_factory
    client = Ideone.new("user", "pass", wsdl: fixture_path("wsdl.xml"))
    assert_instance_of Ideone::Client, client
  end

  def test_test_function
    stub_soap("test_function_ok.xml")

    result = @client.test

    assert_equal "OK", result["error"]
    assert_equal "ideone.com", result["moreHelp"]
    assert_equal "3.14", result["pi"].to_s
    assert_equal "42", result["answerToLifeAndEverything"].to_s
    assert result["oOok"]
  end

  def test_auth_error
    stub_soap("test_function_auth_error.xml")

    error = assert_raises(Ideone::AuthError) { @client.test }
    assert_match(/credentials/i, error.message)
  end

  def test_generic_api_error
    stub_soap("paste_not_found.xml")

    error = assert_raises(Ideone::Error) { @client.submission_status("missing") }
    assert_equal "PASTE_NOT_FOUND", error.message
    refute_instance_of Ideone::AuthError, error
  end

  def test_languages
    stub_soap("get_languages.xml")

    result = @client.languages

    assert_equal "C++ (gcc 8.3)", result["1"]
    assert_equal "Ruby (ruby 2.5.5)", result["17"]
    assert_equal "Python 3 (python 3.12)", result["116"]
    assert_equal %w[1 17 116], result.keys
  end

  def test_create_submission
    stub_soap("create_submission.xml")

    link = @client.create_submission("puts 'hello'", 17)

    assert_equal "VmyZyN", link
    assert_requested :post, "https://ideone.com/api/1/service" do |req|
      req.body.include?("hello") && req.body.include?("<language>17</language>")
    end
  end

  def test_submission_status
    stub_soap("get_submission_status.xml")

    result = @client.submission_status("PD2kqM")

    assert_equal 0, result[:status]
    assert_equal 15, result[:result]
  end

  def test_submission_details
    stub_soap("get_submission_details.xml")

    result = @client.submission_details("PD2kqM")

    assert_equal "OK", result["error"]
    assert_equal "Ruby", result["langName"]
    assert_equal "puts \"hello\"", result["source"]
    assert_equal "", result["stderr"]
    assert_equal 16, result.size
  end

  def test_does_not_leak_request_fields_across_calls
    stub_soap("create_submission.xml")
    @client.create_submission("puts 1", 17)

    stub_soap("test_function_ok.xml")
    @client.test

    assert_requested :post, "https://ideone.com/api/1/service" do |req|
      req.body.include?("testFunction") && !req.body.include?("sourceCode")
    end
  end

  private

  def stub_soap(fixture_name)
    stub_request(:post, "https://ideone.com/api/1/service")
      .to_return(
        status: 200,
        body: fixture(fixture_name),
        headers: { "Content-Type" => "text/xml;charset=UTF-8" }
      )
  end
end
