require 'json'

module Outstream
  class Json
    def self.create(&body_block)
      new body_block
    end

    def each(&out_block)
      e = Enumerator.new {|yielder|
        Collector.new(yielder).collect &@body_block
      }

      out_block ? e.each(&out_block) : e
    end

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
      def add(objs)
        @_collector.add objs
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
      def add(objs)
        objs.each {|key,val|
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
          add_object { add value }
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
