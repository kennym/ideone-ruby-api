# This program is a Ruby API to the Ideone web service. For more
# information about the Ideone API consult
# http://ideone.com/files/ideone-api.pdf
#
# Author::    Kenny Meyer  (knny.myer@gmail.com)
# Copyright:: Copyright (c) 2011
# License::   Distributes under the same terms as Ruby

require 'savon' # SOAP Client
require 'logger'
require 'pp'

Savon.configure do |config|
  config.log = false # TODO: Make this a setting
end


class Ideone

  # Keyword arguments
  # -----------------
  #
  # * username: a valid Ideone username
  # * password: a valid Ideone password
  def initialize(username=nil, password=nil)
    @username = username
    @password = password
    
    @client = Savon::Client.new do
      wsdl.document = "http://ideone.com/api/1/service.wsdl"
    end

    @request_body = {
      :user => @username,
      :pass => @password,
    }
    @languages_cache = nil
    # Set up logger
    @log = Logger.new(STDOUT)
    @log.level = Logger::WARN

  end

  # Create a submission and upload it to Ideone.
  #
  # Keyword Arguments
  # -----------------
  #  
  # * source_code: a string of the program's source code
  # * lang_id: the ID of the programming language.
  # * std_input: the string to pass to the program on stdin
  # * run: a boolean flag to signifying if Ideone should compile and
  #        run the program
  # * is_private: a boolean flag to toggle visibility of code to others
  # 
  # Returns
  # -------
  # 
  # A hash with the keys error and link.  The link is the
  # unique id of the program.  The URL of the submission is
  # http://ideone.com/LINK.
  def create_submission(source_code, lang_id, std_input="", run=true,
                        is_private=false)
    request_body = @request_body
    request_body[:sourceCode] = source_code
    request_body[:language] = lang_id
    request_body[:input] = std_input
    request_body[:run] = run
    request_body[:private] = is_private
    response = @client.request :createSubmission, :body => @request_body

    return pp response.to_hash[:create_submission_response][:return][:item]
  end

  # Given the unique link of a submission, returns its current status.
  #  
  # Keyword Arguments
  # -----------------
  # 
  # * link: the unique id string of a submission
  # 
  # Returns
  # -------
  # 
  # A hash of the error, the result code and the status code.
  # 
  # Notes
  # -----
  # 
  # Status specifies the stage of execution.
  # 
  # * status < 0 means the program awaits compilation
  # * status == 0 means the program is done
  # * status == 1 means the program is being compiled
  # * status == 3 means the program is running
  # 
  # Result specifies how the program finished.
  # 
  # * result == 0 means not running, the program was submitted
  #               with run=False
  # * result == 11 means compilation error
  # * result == 12 means runtime error
  # * result == 13 means timelimit exceeded
  # * result == 15 means success
  # * result == 17 means memory limit exceeded
  # * result == 19 means illegal system call
  # * result == 20 means Ideone internal error, submit a bug report
  def submission_status(link)
    request_body = @request_body
    request_body[:link] = link
    response = @client.request :getSubmissionStatus, :body => request_body
    
    return pp response.to_hash[:get_submission_status_response][:return][:item]
  end

  # Return a hash of requested details about a submission with the id
  # of link.
  #
  # Keyword Arguments
  # -----------------
  #
  # * link: the unique string ID of a submission
  # * with_source: should we request the source code
  # * with_input: request the program input
  # * with_output: request the program output
  # * with_stderr: request the error output
  # * with_cmpinfo: request compilation flags
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
    begin
      response = @client.request :getSubmissionDetails, :body => request_body
    rescue Savon::SOAP::Fault => fault
      @log.warn fault.to_s
      raise fault
    end
    
    return pp response.to_hash[:get_submission_details_response][:return][:item]
  end

  # Get a list of supported languages and cache it.
  def languages
    if !@languages_cache
      response = @client.request :getLanguages, :body => @request_body
      languages = response.to_hash[:get_languages_response][:return][:item]
      @languages_cache = languages
    end
    return pp @languages_cache
  end
  
  # A test function that always returns the same thing.
  def test
    response = @client.request :testFunction, :body => @request_body
    
    return pp response.to_hash[:test_function_response][:return][:item]
  end
end
