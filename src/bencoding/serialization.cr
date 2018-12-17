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
          @{{ivar.name}} = parser.read_any.as({{ivar.type}})
        {% else %}
          # unknown field
        {% end %}
      {% end %}
    end

    def bencode(builder : ::Bencoding::Builder)
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(::Bencoding::Field) %}
        {% unless ann.is_a?(NilLiteral) %}
          @{{ivar.name}}.bencode(builder)
        {% else %}
          # unknown field
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
      list = parser.read_list
      i = 0
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(::Bencoding::Field) %}
        {% unless ann.is_a?(NilLiteral) %}
          @{{ivar.name}} = list[{{ i }}].as({{ivar.type}})
          i += 1
        {% else %}
          # unknown field
        {% end %}
      {% end %}
    end

    def bencode(builder : ::Bencoding::Builder)
      builder.list do
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Bencoding::Field) %}
          {% unless ann.is_a?(NilLiteral) %}
            @{{ivar.name}}.bencode(builder)
          {% else %}
            # unknown field
          {% end %}
        {% end %}
      end
    end
  end

  module Serializable::Hash
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
      dict = parser.read_dictionary
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(::Bencoding::Field) %}
        {% unless ann.is_a?(NilLiteral) %}
          @{{ivar.name}} = dict[{{ivar.name.stringify}}].as({{ivar.type}})
        {% else %}
          # unknown field
        {% end %}
      {% end %}
    end

    def bencode(builder : ::Bencoding::Builder)
      builder.dictionary do
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Bencoding::Field) %}
          {% unless ann.is_a?(NilLiteral) %}
            builder.field {{ivar.name.stringify}} do
              @{{ivar.name}}.bencode(builder)
            end
          {% else %}
            # unknown field
          {% end %}
        {% end %}
      end
    end
  end
end
