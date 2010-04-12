$:.unshift File.dirname(__FILE__)

module Less
  class Engine
    attr_reader :css, :less

    def initialize obj, options = {}
      @less = if obj.is_a? File
        @path = File.dirname File.expand_path(obj.path)
        obj.read
      elsif obj.is_a? String
        obj.dup
      else
        raise ArgumentError, "argument must be an instance of File or String!"
      end

      @options = options
      @parser = Johnson::Runtime.new.load(
        "#{File.dirname(__FILE__)}/engine/less.js")
    end

    def parse &blk
      @parser.parser().parse(self.prepare) do |err, tree|
        if err
          raise Less::ParseError, err.message
        else
          yield tree
        end
      end
    end
    alias :to_tree :parse

    def to_css &blk
      @css || @css = self.parse {|tree| blk.call(tree.toCSS) }
    end

    def prepare
      @less.gsub(/\r\n/, "\n").gsub(/\t/, '  ')
    end
  end
end
