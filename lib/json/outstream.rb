module JSON
  class OutStream
    def self.generate(&body_block)
      new body_block
    end

    def each(&out_block)
      @out_block = out_block
      write_object {
        @body_block[self]
      }
      @out_block = nil
    end

    def to_s
      "".tap {|s| each {|str| s.concat str } }
    end

    def write(obj, &block)
      parents = obj.class.ancestors
      if (parents & [String, Symbol]).size == 1
        write_key obj
        write_object(&block)
      elsif parents.include?Hash
        obj.each {|key,value|
          write_key key
          if value.respond_to?:each
            if value.is_a?Hash
              write_object { write value, &block }
            else
              write_array value, &block
            end
          else
            write_value value, &block
          end
        }
      end
    end


    private
    def initialize(body_block)
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
    def write_array(a, &block)
      print "["
      a.each_with_index do |v,i|
        print "," if i > 0
        write_value v, &block
      end
      print "]"
    end
    def write_value(value)
      if block_given?
        print yield(value).to_json
      else
        print value.to_json
      end
    end
  end
end
