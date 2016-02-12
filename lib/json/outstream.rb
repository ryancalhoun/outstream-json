require 'json'

module JSON
  class OutStream
    def self.generate(&body_block)
      new {
        write_object {
          if body_block.arity == 1
            body_block[self]
          else
            @body_block = body_block
            self.class.send(:define_method, :__call_block, &@body_block)
            __call_block
          end
        }
      }
    end

    def each(&out_block)
      @out_block = out_block
      instance_eval &@body_block
      @out_block = nil
    end

    def to_s
      "".tap {|s| each {|str| s.concat str } }
    end

    def write(objs)
      objs.each {|key,val|
        write_key key
        write_value val
      }
    end

    private
    def initialize(&body_block)
      @count = [0]
      @body_block = body_block
    end

    def print(str)
      @out_block[str]
    end
    def write_key(key)
      print "," if @count.last > 0
      print "#{key.to_json}:"
      @count[@count.size-1] += 1
    end
    def write_object
      print "{"
      @count.push 0
      yield
      @count.pop
      print "}"
    end
    def write_array(a)
      print "["
      a.enum_for(:each).each_with_index {|v,i|
        print "," if i > 0
        write_value v
      }
      print "]"
    end
    def write_value(value)
      if value.respond_to?:each_pair
        write_object { write value }
      elsif value.respond_to?:each
        write_array value
      elsif value.respond_to?:call
        write_value value.call
      else
        print value.to_json
      end
    end
  end
end
