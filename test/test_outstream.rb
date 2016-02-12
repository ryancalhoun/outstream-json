require 'test/unit'
require 'json/outstream'
require 'json'

class TestOutStream < Test::Unit::TestCase

  def testScalar
    out = JSON::OutStream.generate {|json|
      json.write "foo" => "bar"
    }

    assert_equal '{"foo":"bar"}', out.to_s
  end
  def testMultipleScalars
    out = JSON::OutStream.generate {|json|
      json.write "foo" => "bar", "wow" => true
    }

    assert_equal '{"foo":"bar","wow":true}', out.to_s
  end
  def testArray
    out = JSON::OutStream.generate {|json|
      json.write "foo" => [1,2,3]
    }

    assert_equal '{"foo":[1,2,3]}', out.to_s
  end
  def testHash
    out = JSON::OutStream.generate {|json|
      json.write "foo" => {a: 1, b: 2}
    }

    assert_equal '{"foo":{"a":1,"b":2}}', out.to_s
  end

end

