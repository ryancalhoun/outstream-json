require 'test/unit'
require 'json-outstream'

class TestOutStream < Test::Unit::TestCase

  def testScalar
    out = JSON::OutStream.generate {
      write "foo" => "bar"
    }
    assert_equal '{"foo":"bar"}', out.to_s
  end
  def testScalarWithBlockParam
    out = JSON::OutStream.generate {|json|
      json.write "foo" => "bar"
    }
    assert_equal '{"foo":"bar"}', out.to_s
  end
  def testMultipleScalars
    out = JSON::OutStream.generate {
      write "foo" => "bar", "wow" => true
    }

    assert_equal '{"foo":"bar","wow":true}', out.to_s
  end
  def testArray
    out = JSON::OutStream.generate {
      write "foo" => [1,2,3]
    }

    assert_equal '{"foo":[1,2,3]}', out.to_s
  end
  def testHash
    out = JSON::OutStream.generate {
      write "foo" => {a: 1, b: 2}
    }
    assert_equal '{"foo":{"a":1,"b":2}}', out.to_s
  end

  def testProc
    out = JSON::OutStream.generate {
      write "foo" => lambda { "bar" }
    }
    assert_equal '{"foo":"bar"}', out.to_s
  end
  def testProcArray
    out = JSON::OutStream.generate {
      write "foo" => lambda { [1,2,3] }
    }
    assert_equal '{"foo":[1,2,3]}', out.to_s
  end
  def testProcArrayEach
    out = JSON::OutStream.generate {
      write "foo" => lambda { [1,2,3].each }
    }
    assert_equal '{"foo":[1,2,3]}', out.to_s
  end
  def testProcHash
    out = JSON::OutStream.generate {
      write "foo" => lambda { { a: 1, b: 2 } }
    }
    assert_equal '{"foo":{"a":1,"b":2}}', out.to_s
  end
  def testProcHashOfProc
    out = JSON::OutStream.generate {
      write "foo" => lambda { { a: lambda { 1 }, b: lambda { 2 } } }
    }
    assert_equal '{"foo":{"a":1,"b":2}}', out.to_s
  end

  def testLocalVariableScope
    x = "bar"
    out = JSON::OutStream.generate {
      y = "cool"
      write "foo" => x, "wow" => y
    }
    assert_equal '{"foo":"bar","wow":"cool"}', out.to_s
  end

end

