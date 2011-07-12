require 'helper'

USER = '' # YOUR IDEONE USER
PASS = '' # YOUR IDEONE PASSWORD

class TestIdeoneRubyApi < Test::Unit::TestCase
  def test_initialize
    instance = Ideone.new
    assert_not_nil(instance)
    
    instance = Ideone.new(USER, PASS)
    assert_not_nil(instance)
  end

  def test_ideone_test
    instance = Ideone.new(USER, PASS)

    result = instance.test
    puts result
    assert_not_nil result
  end

  def test_languages
    instance = Ideone.new(USER, PASS)

    result = instance.languages

    puts result
    assert_not_nil result
  end

  def test_create_submission
    instance = Ideone.new(USER, PASS)

    code = <<-eos
puts "This is a test submission created from ideone-ruby-api. https://github.com/kennym/ideone-gem/blob/master/lib/ideone.rb"
    eos
    result = instance.create_submission(code, 17)

    puts result
    assert_not_nil result
  end

  def test_submission_status
    instance = Ideone.new(USER, PASS)

    result = instance.submission_status("VWMD7")
    puts result
    assert_not_nil result
  end
  
  def test_submission_details
    instance = Ideone.new(USER, PASS)

    result = instance.submission_details("ZUIWF")
    puts result
    assert_not_nil result
  end
end
