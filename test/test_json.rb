require 'test/unit'
require 'outstream-json'

class TestJson < Test::Unit::TestCase

  def testScalar
    out = Outstream::Json.create {
      write "foo" => "bar"
    }
    assert_equal '{"foo":"bar"}', out.to_s
  end
  def testScalarWithBlockParam
    out = Outstream::Json.create {|json|
      json.write "foo" => "bar"
    }
    assert_equal '{"foo":"bar"}', out.to_s
  end
  def testMultipleScalars
    out = Outstream::Json.create {
      write "foo" => "bar", "wow" => true
    }

    assert_equal '{"foo":"bar","wow":true}', out.to_s
  end
  def testArray
    out = Outstream::Json.create {
      write "foo" => [1,2,3]
    }

    assert_equal '{"foo":[1,2,3]}', out.to_s
  end
  def testHash
    out = Outstream::Json.create {
      write "foo" => {a: 1, b: 2}
    }
    assert_equal '{"foo":{"a":1,"b":2}}', out.to_s
  end

  def testProc
    out = Outstream::Json.create {
      write "foo" => lambda { "bar" }
    }
    assert_equal '{"foo":"bar"}', out.to_s
  end
  def testProcArray
    out = Outstream::Json.create {
      write "foo" => lambda { [1,2,3] }
    }
    assert_equal '{"foo":[1,2,3]}', out.to_s
  end
  def testProcArrayEach
    out = Outstream::Json.create {
      write "foo" => lambda { [1,2,3].each }
    }
    assert_equal '{"foo":[1,2,3]}', out.to_s
  end
  def testProcHash
    out = Outstream::Json.create {
      write "foo" => lambda { { a: 1, b: 2 } }
    }
    assert_equal '{"foo":{"a":1,"b":2}}', out.to_s
  end
  def testProcHashOfProc
    out = Outstream::Json.create {
      write "foo" => lambda { { a: lambda { 1 }, b: lambda { 2 } } }
    }
    assert_equal '{"foo":{"a":1,"b":2}}', out.to_s
  end

  def testLocalVariableScope
    x = "bar"
    out = Outstream::Json.create {
      y = "cool"
      write "foo" => x, "wow" => y
    }
    assert_equal '{"foo":"bar","wow":"cool"}', out.to_s
  end

  def testEnumerator
    x = "fun"
    out = Outstream::Json.create {
      write "foo" => "bar", "wow" => x
    }
    e = out.each
    assert_equal '{', e.next
    assert_equal '"foo"', e.next
    assert_equal ':', e.next
    assert_equal '"bar"', e.next
    assert_equal ',', e.next
    assert_equal '"wow"', e.next
    assert_equal ':', e.next

    x.upcase!
    assert_equal '"FUN"', e.next
    assert_equal '}', e.next

  end

end

