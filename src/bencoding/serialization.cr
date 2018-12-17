require "./builder"
require "./parser"

module Bencoding
  annotation Field
  end

  module Serializable::Common
    macro included
      # Define a `new` directly in the included type,
      # so it overloads well with other possible initializes

      def self.new(parser : ::Bencoding::Parser)
        instance = allocate
        instance.initialize(__parser_for_bencoding: parser)
        GC.add_finalizer(instance) if instance.responds_to?(:finalize)
        instance
      end

      # When the type is inherited, carry over the `new`
      # so it can compete with other possible intializes

      macro inherited
        def self.new(parser : ::Bencoding::Parser)
          super
        end
      end
    end
  end

  module Serializable

    macro included
      # Define a `new` directly in the included type,
      # so it overloads well with other possible initializes

      def self.new(parser : ::Bencoding::Parser)
        instance = allocate
        instance.initialize(__parser_for_bencoding: parser)
        GC.add_finalizer(instance) if instance.responds_to?(:finalize)
        instance
      end

      # When the type is inherited, carry over the `new`
      # so it can compete with other possible intializes

      macro inherited
        def self.new(parser : ::Bencoding::Parser)
          super
        end
      end
    end

    def initialize(*, __parser_for_bencoding parser : ::Bencoding::Parser)
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(::Bencoding::Field) %}
        {% unless ann.is_a?(NilLiteral) %}
          @{{ivar.name}} = {{ivar.type}}.new(parser)
        {% else %}
          @{{ivar.name}} = {{ivar.type}}.new(parser)
        {% end %}
      {% end %}
    end

    def bencode(builder : ::Bencoding::Builder)
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(::Bencoding::Field) %}
        {% unless ann.is_a?(NilLiteral) %}
          @{{ivar.name}}.bencode(builder)
        {% else %}
          @{{ivar.name}}.bencode(builder)
        {% end %}
      {% end %}
    end
  end

  module Serializable::List
    macro included
      # Define a `new` directly in the included type,
      # so it overloads well with other possible initializes

      def self.new(parser : ::Bencoding::Parser)
        instance = allocate
        instance.initialize(__parser_for_bencoding: parser)
        GC.add_finalizer(instance) if instance.responds_to?(:finalize)
        instance
      end

      # When the type is inherited, carry over the `new`
      # so it can compete with other possible intializes

      macro inherited
        def self.new(parser : ::Bencoding::Parser)
          super
        end
      end
    end

    def initialize(*, __parser_for_bencoding parser : ::Bencoding::Parser)
      parser.read_begin_list
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(::Bencoding::Field) %}
        {% ignore = ann && ann[:ignore].is_a?(BoolLiteral) ? ann[:ignore] : false %}
        {% unless ignore %}
          @{{ivar.name}} = {{ivar.type}}.new(parser)
        {% end %}
      {% end %}
      parser.read_end_list
    end

    def bencode(builder : ::Bencoding::Builder)
      builder.list do
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Bencoding::Field) %}
          {% ignore = ann && ann[:ignore].is_a?(BoolLiteral) ? ann[:ignore] : false %}
          {% unless ignore %}
            @{{ivar.name}}.bencode(builder)
          {% end %}
        {% end %}
      end
    end
  end

  module Serializable::Dictionary
    macro included
      # Define a `new` directly in the included type,
      # so it overloads well with other possible initializes

      def self.new(parser : ::Bencoding::Parser)
        instance = allocate
        instance.initialize(__parser_for_bencoding: parser)
        GC.add_finalizer(instance) if instance.responds_to?(:finalize)
        instance
      end

      # When the type is inherited, carry over the `new`
      # so it can compete with other possible intializes

      macro inherited
        def self.new(parser : ::Bencoding::Parser)
          super
        end
      end
    end

    def initialize(*, __parser_for_bencoding parser : ::Bencoding::Parser)
      parser.read_begin_dictionary
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(::Bencoding::Field) %}
        {% ignore = ann && ann[:ignore].is_a?(BoolLiteral) ? ann[:ignore] : false %}
        {% key = ann && ann[:key].is_a?(StringLiteral) ? ann[:key] : ivar.name %}
        {% unless ignore %}
          key = parser.read_string
          @{{ivar.name}} = {{ivar.type}}.new(parser)
        {% end %}
      {% end %}
      parser.read_end_dictionary
    end

    def bencode(builder : ::Bencoding::Builder)
      builder.dictionary do
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Bencoding::Field) %}
          {% ignore = ann && ann[:ignore].is_a?(BoolLiteral) ? ann[:ignore] : false %}
          {% key = ann && ann[:key].is_a?(StringLiteral) ? ann[:key] : ivar.name %}
          {% unless ignore %}
            builder.field {{key}} do
              @{{ivar.name}}.bencode(builder)
            end
          {% end %}
        {% end %}
      end
    end
  end
end
