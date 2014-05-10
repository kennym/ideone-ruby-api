# This program is a Ruby API to the Ideone web service. For more
# information about the Ideone API consult
# http://ideone.com/files/ideone-api.pdf
#
# Author::    Kenny Meyer  (kenny@kennymeyer.net)
# Copyright:: Copyright (c) 2014
# License::   Distributes under the same terms as Ruby

require_relative 'ideone/exceptions'
require 'savon' # SOAP Client

module Ideone
  def self.new(username, password, verbose=false)
    return Ideone::Client.new(username, password, verbose)
  end

  class Client
    def initialize(username=nil, password=nil, verbose=false)
      @client = Savon.client(wsdl: "http://ideone.com/api/1/service.wsdl", log: verbose)
      @languages_cache = nil
      @request_body = {
        :user => username,
        :pass => password,
      }
    end

    def create_submission(source_code, lang_id, std_input="", run=true,
                          is_private=false)
      request_body = @request_body
      request_body[:sourceCode] = source_code
      request_body[:language] = lang_id
      request_body[:input] = std_input
      request_body[:run] = run
      request_body[:private] = is_private

      response = call_request(:create_submission, :message => @request_body)

      return response.to_hash[:create_submission_response][:return][:item][1][:value]
    end

    def submission_status(link)
      request_body = @request_body
      request_body[:link] = link

      response = call_request(:get_submission_status, :message => request_body)

      status = response.to_hash[:get_submission_status_response][:return][:item][1][:value].to_i
      result = response.to_hash[:get_submission_status_response][:return][:item][2][:value].to_i

      if status < 0
        status = -1
      end

      return { :status => status, :result => result }
    end

    def submission_details(link,
                           with_source=true,
                           with_input=true,
                           with_output=true,
                           with_stderr=true,
                           with_cmpinfo=true)
      request_body = @request_body
      request_body[:link] = link
      request_body[:withSource] = with_source
      request_body[:withInput] = with_input
      request_body[:withOutput] = with_output
      request_body[:withStderr] = with_stderr
      request_body[:withCmpinfo] = with_cmpinfo

      response = call_request(:get_submission_details, :message => request_body)

      details = response.to_hash[:get_submission_details_response][:return][:item]

      create_dict(details)
    end

    # Get a list of supported languages and cache it.
    def languages
      unless @languages_cache
        response = call_request(:get_languages, :message => @request_body)

        languages = response.to_hash[:get_languages_response][:return][:item][1][:value][:item]
        # Create a sorted hash
        @languages_cache = Hash[create_dict(languages).sort_by{|k,v| k.to_i}]
      end
      return @languages_cache
    end

    # A test function that always returns the same thing.
    def test
      response = call_request(:test_function, :message => @request_body)

      items = response.to_hash[:test_function_response][:return][:item]

      return create_dict(items)
    end

    private

    def check_error(response, function_response)
      error = get_error(response.to_hash, function_response)
      if error != 'OK'
        raise Ideone::AuthError, "Invalid Ideone credentials provided"
      end
    end

    def call_request(api_endpoint, **params)
      begin
        response = @client.call(api_endpoint, params)
      rescue Exception => e
        raise e
      end
      check_error(response, "#{api_endpoint}_response".to_sym)
      return response
    end

    def get_error(response, function_response)
      begin
        return response[function_response][:return][:item][0][:value]
      rescue
        return response[function_response][:return][:item][:value]
      end
    end

    def create_dict(items)
      dict = {}

      items.each do |item|
        key = item[:key]
        value = item[:value]
        value = "" if value == {:"@xsi:type"=>"xsd:string"}
        dict[key] = value
      end

      dict
    end
  end
end
