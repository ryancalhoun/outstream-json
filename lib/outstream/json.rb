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
      def write(objs)
        @_collector.write objs
      end
    end

    class Collector
      def initialize(yielder)
        @yielder = yielder
        @count = [0]
      end
      def collect(&block)
        write_object {
          receiver = Receiver.new self
          if block.arity == 1
            block[receiver]
          else
            (class << receiver; self; end).send(:define_method, :__call_block, &block)
            receiver.__call_block
          end
        }
      end
      def print(str)
        @yielder << str
      end
      def write(objs)
        objs.each {|key,val|
          write_key key
          write_value val
        }
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
    end
  end
end
