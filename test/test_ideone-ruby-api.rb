require 'helper'

USER = '' # YOUR IDEONE USER
PASS = '' # YOUR IDEONE PASSWORD

class TestIdeoneRubyApi < Test::Unit::TestCase
  def test_initialize
    omit_if(USER.empty? || PASS.empty?, "Specify ideone USER and PASS")
    
    instance = Ideone.new
    assert_not_nil(instance)
    
    instance = Ideone.new(USER, PASS)
    assert_not_nil(instance)
  end

  def test_ideone_test
    omit_if(USER.empty? || PASS.empty?, "Specify ideone USER and PASS")
    
    instance = Ideone.new(USER, PASS)

    result = instance.test

    def compare_intersecting_keys(a, b)
      (a.keys & b.keys).all? {|k| a[k] == b[k]}
    end

    assert compare_intersecting_keys(result,{"error"=>"OK", "moreHelp"=>"ideone.com", "pi"=>"3.14", "answerToLifeAndEverything"=>"42", "oOok"=>true}) == true
    assert_not_nil result
  end

  def test_languages
    omit_if(USER.empty? || PASS.empty?, "Specify ideone USER and PASS")
    
    instance = Ideone.new(USER, PASS)

    result = instance.languages

    assert result.count > 10
    assert_not_nil result
  end

  def test_create_submission
    omit_if(USER.empty? || PASS.empty?, "Specify ideone USER and PASS")
    
    instance = Ideone.new(USER, PASS)

    code = <<-eos
puts "This is a test submission created from ideone-ruby-api. https://github.com/kennym/ideone-gem/blob/master/lib/ideone.rb"
    eos
    result = instance.create_submission(code, 17)

    assert result.is_a?(String)
    assert_not_nil result
  end

  def test_submission_status
    omit_if(USER.empty? || PASS.empty?, "Specify ideone USER and PASS")
    
    instance = Ideone.new(USER, PASS)

    result = instance.submission_status("nDRJO")

    assert_not_nil result
    assert_not_nil result[:status]
    assert_not_nil result[:result]
  end
  
  def test_submission_details
    omit_if(USER.empty? || PASS.empty?, "Specify ideone USER and PASS")
    
    instance = Ideone.new(USER, PASS)

    result = instance.submission_details("nDRJO")

    assert result.count == 16
    assert_not_nil result
  end
end
