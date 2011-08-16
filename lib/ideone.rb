# This program is a Ruby API to the Ideone web service. For more
# information about the Ideone API consult
# http://ideone.com/files/ideone-api.pdf
#
# Author::    Kenny Meyer  (knny.myer@gmail.com)
# Copyright:: Copyright (c) 2011
# License::   Distributes under the same terms as Ruby

require 'savon' # SOAP Client

class Ideone

  def initialize(username=nil, password=nil)
    @username = username
    @password = password
    
    @client = Savon::Client.new do
      wsdl.document = "http://ideone.com/api/1/service.wsdl"
    end

    HTTPI.log = false
    disable_savon_logging()
    
    @request_body = {
      :user => @username,
      :pass => @password,
    }
    @languages_cache = nil
  end

  def create_submission(source_code, lang_id, std_input="", run=true,
                        is_private=false)
    request_body = @request_body
    request_body[:sourceCode] = source_code
    request_body[:language] = lang_id
    request_body[:input] = std_input
    request_body[:run] = run
    request_body[:private] = is_private
    response = @client.request :createSubmission, :body => @request_body

    check_error(response, :create_submission_response)
    return response.to_hash[:create_submission_response][:return][:item][1][:value]
  end

  def submission_status(link)
    request_body = @request_body
    request_body[:link] = link
    response = @client.request :getSubmissionStatus, :body => request_body

    check_error(response, :get_submission_status_response)

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

    response = @client.request :getSubmissionDetails, :body => request_body
    
    check_error(response, :get_submission_details_response)

    details = response.to_hash[:get_submission_details_response][:return][:item]
    
    create_dict(details)
  end

  # Get a list of supported languages and cache it.
  def languages
    unless @languages_cache
      response = @client.request :getLanguages, :body => @request_body

      check_error(response, :get_languages_response)

      languages = response.to_hash[:get_languages_response][:return][:item][1][:value][:item]
      # Create a sorted hash
      @languages_cache = Hash[create_dict(languages).sort_by{|k,v| k.to_i}]
    end
    return @languages_cache
  end
  
  # A test function that always returns the same thing.
  def test
    response = @client.request :testFunction, :body => @request_body

    check_error(response, :test_function_response)

    items = response.to_hash[:test_function_response][:return][:item]
    create_dict(items)
  end

  private

  def disable_savon_logging
    Savon.configure do |config|
      config.log = false
    end
  end
  
  def check_error(response, function_response)
    error = get_error(response.to_hash, function_response)
    if error != 'OK'
      raise error
    end
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
