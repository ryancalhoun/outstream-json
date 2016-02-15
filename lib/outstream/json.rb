require 'json'

module Outstream
  # Produce a stream of JSON tokens.
  class Json
    # Define an output JSON object, given a block. The block
    # is executed in a context which provides the add method,
    # for adding key-value pairs to the object.
    #
    # Example:
    #   Outstream::Json.create do
    #     add string: "hello", number: 42
    #     add array: [1,2,3]
    #     add "nested_object" {
    #       add "foo" => "bar"
    #     }
    #   end
    def self.create(&body_block)
      new body_block
    end

    # Iterate the output tokens. The block will receive JSON delimeters individually as strings,
    # and string values as quoted strings. If called without a block, returns an enumerator.
    #
    # Example:
    #   json.each {|token| puts token} => nil
    #   json.each => an_enumerator
    def each(&out_block)
      e = Enumerator.new {|yielder|
        Collector.new(yielder).collect &@body_block
      }

      if out_block
        e.each(&out_block)
        nil
      else
        e
      end
    end

    # Produce a compact string of the JSON. The entire string is produced at once; this is not
    # suitable for very large JSON output.
    def to_s
      "".tap {|s| each {|str| s.concat str } }
    end

    private

    def initialize(body_block)
      @body_block = body_block
    end

    class Receiver
      def initialize(collector)
        @_collector = collector
      end
      def add(objs, &block)
        @_collector.add objs, &block
      end
    end

    class Collector
      def initialize(yielder)
        @yielder = yielder
        @count = [0]
      end
      def collect(&block)
        add_object {
          receiver = Receiver.new self
          if block.arity == 1
            block[receiver]
          else
            (class << receiver; self; end).send(:define_method, :__call_block, &block)
            receiver.__call_block
          end
        }
      end
      def write(str)
        @yielder << str
      end
      def add(objs, &block)
        if block
          add_key objs
          add_object &block
        else
          add_to_object objs
        end
      end
      def add_to_object(objs)
        objs.each_pair {|key,val|
          add_key key
          add_value val
        }
      end
      def add_key(key)
        write "," if @count.last > 0
        write key.to_json
        write ":"
        @count[@count.size-1] += 1
      end
      def add_object
        write "{"
        @count.push 0
        result = yield
        @count.pop
        write "}"

        result
      end
      def add_array(a)
        write "["
        a.enum_for(:each).each_with_index {|v,i|
          write "," if i > 0
          add_value v
        }
        write "]"
      end
      def add_value(value)
        if value.respond_to?:each_pair
          add_object { add_to_object value }
        elsif value.respond_to?:each
          add_array value
        elsif value.respond_to?:call
          add_value value.call
        else
          write value.to_json
        end
      end
    end
  end
end
