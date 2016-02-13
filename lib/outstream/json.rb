require 'json'

module Outstream
  class Json
    def self.generate(&body_block)
      new body_block
    end

    def each(&out_block)
      e = Enumerator.new {|yielder|
        @yielder = yielder
        write_object {
          receiver = Receiver.new self
          if @body_block.arity == 1
            @body_block[receiver]
          else
            (class << receiver; self; end).send(:define_method, :__call_block, &@body_block)
            receiver.__call_block
          end
        }
      }

      out_block ? e.each(&out_block) : e
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
    def initialize(body_block)
      @count = [0]
      @body_block = body_block
    end

    def print(str)
      @yielder << str
    end
    def write_key(key)
      print "," if @count.last > 0
      print key.to_json
      print ":"
      @count[@count.size-1] += 1
    end
    def write_object
      print "{"
      @count.push 0
      result = yield
      @count.pop
      print "}"

      result
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

    class Receiver
      def initialize(json)
        @_json = json
      end
      def write(objs)
        @_json.write objs
      end
    end

  end
end
