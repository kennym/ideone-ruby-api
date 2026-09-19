# frozen_string_literal: true

# Ruby bindings for the Ideone SOAP API.
# See https://ideone.com/api/1/service.wsdl
#
# Author::    Kenny Meyer (kenny@kennymeyer.net)
# Copyright:: Copyright (c) 2011-2026
# License::   MIT

require "savon"
require_relative "ideone/exceptions"
require_relative "ideone/version"

module Ideone
  def self.new(username, password, verbose = false, **options)
    Client.new(username, password, verbose, **options)
  end

  class Client
    WSDL_URL = "https://ideone.com/api/1/service.wsdl"

    def initialize(username = nil, password = nil, verbose = false, wsdl: WSDL_URL)
      @client = Savon.client(
        wsdl: wsdl,
        log: verbose,
        convert_request_keys_to: :none,
        follow_redirects: true
      )
      @languages_cache = nil
      @credentials = {
        user: username,
        pass: password
      }
    end

    def create_submission(source_code, lang_id, std_input = "", run = true,
                          is_private = false)
      map = response_map(
        call_request(:create_submission, {
          sourceCode: source_code,
          language: lang_id,
          input: std_input,
          run: run,
          private: is_private
        }),
        :create_submission_response
      )
      map["link"]
    end

    def submission_status(link)
      map = response_map(
        call_request(:get_submission_status, { link: link }),
        :get_submission_status_response
      )

      status = map["status"].to_i
      result = map["result"].to_i
      status = -1 if status < 0

      { status: status, result: result }
    end

    def submission_details(link,
                           with_source = true,
                           with_input = true,
                           with_output = true,
                           with_stderr = true,
                           with_cmpinfo = true)
      response_map(
        call_request(:get_submission_details, {
          link: link,
          withSource: with_source,
          withInput: with_input,
          withOutput: with_output,
          withStderr: with_stderr,
          withCmpinfo: with_cmpinfo
        }),
        :get_submission_details_response
      )
    end

    def languages
      @languages_cache ||= begin
        map = response_map(call_request(:get_languages), :get_languages_response)
        create_dict(array_wrap(nested_items(map["languages"]))).sort_by { |k, _| k.to_i }.to_h
      end
    end

    def test
      response_map(call_request(:test_function), :test_function_response)
    end

    private

    def call_request(api_endpoint, extra = {})
      response = @client.call(api_endpoint, message: @credentials.merge(extra))
      check_error(response, :"#{api_endpoint}_response")
      response
    rescue Savon::Error => e
      raise Error, e.message
    end

    def check_error(response, function_response)
      error = response_map(response, function_response)["error"]
      return if error == "OK"

      if error == "AUTH_ERROR"
        raise AuthError, "Invalid Ideone credentials provided"
      end

      raise Error, error.to_s
    end

    def response_map(response, function_response)
      items = response.to_hash.dig(function_response, :return, :item)
      raise Error, "Unexpected response from Ideone API" if items.nil?

      create_dict(array_wrap(items))
    end

    def create_dict(items)
      items.each_with_object({}) do |item, dict|
        dict[item[:key]] = normalize_value(item[:value])
      end
    end

    def nested_items(value)
      return value[:item] if value.is_a?(Hash) && value.key?(:item)

      value
    end

    def array_wrap(value)
      value.is_a?(Array) ? value : [value]
    end

    def normalize_value(value)
      return "" if value.nil?
      return "" if value.is_a?(Hash) && value.keys.all? { |key| key.to_s.start_with?("@") }

      value
    end
  end
end
