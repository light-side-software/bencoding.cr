require "./builder"

class Object
  def bencode : String
    String.build do |str|
      bencode Bencoding::Builder.new(str)
    end
  end

  def bencode(builder : Bencoding::Builder)
    raise "Unimplemented method: #{__METHOD__}"
  end
end

struct Bool
  def bencode(builder : Bencoding::Builder)
    builder.integer(to_unsafe)
  end
end

struct Char
  def bencode(builder : Bencoding::Builder)
    builder.integer(ord)
  end
end

struct Int
  def bencode(builder : Bencoding::Builder)
    builder.integer(self)
  end
end

class String
  def bencode(builder : Bencoding::Builder)
    builder.string(self)
  end
end

struct Symbol
  def bencode(builder : Bencoding::Builder)
    builder.string(to_s)
  end
end

class Array
  def bencode(builder : Bencoding::Builder)
    builder.list do
      each &.bencode(builder)
    end
  end
end

struct Set
  def bencode(builder : Bencoding::Builder)
    builder.list do
      each &.bencode(builder)
    end
  end
end

class Hash
  def bencode(builder : Bencoding::Builder)
    builder.dictionary do
      each do |key, value|
        builder.field key do
          value.bencode(builder)
        end
      end
    end
  end
end

struct Tuple
  def bencode(builder : Bencoding::Builder)
    builder.list do
      {% for i in 0...T.size %}
        self[{{i}}].bencode(builder)
      {% end %}
    end
  end
end

struct NamedTuple
  def bencode(builder : Bencoding::Builder)
    builder.dictionary do
      {% for key in T.keys %}
        builder.field {{key.stringify}} do
          self[{{key.symbolize}}].bencode(builder)
        end
      {% end %}
    end
  end
end

struct Time::Format
  def bencode(value : Time, builder : Bencoding::Builder)
    format(value).bencode(builder)
  end
end

struct Enum
  def bencode(builder : Bencoding::Builder)
    builder.integer(value)
  end
end

struct Time
  # Emits a string formated according to [RFC 3339](https://tools.ietf.org/html/rfc3339)
  # ([ISO 8601](http://xml.coverpages.org/ISO-FDIS-8601.pdf) profile).
  #
  # The encoded format itself does not specify a time data type, this method just
  # assumes that a string holding a RFC 3339 time format will be interpreted as
  # a time value.
  #
  # See `#bdecode` for reference.
  def bencode(builder : Bencoding::Builder)
    builder.string(Time::Format::RFC_3339.format(self, fraction_digits: 0))
  end
end

# Converter to be used with `Benconding::Field` annotation
# to serialize a `Time` instance as the number of seconds
# since the unix epoch. See `Time#to_unix`.
#
# ```
# require "bencoding"
#
# class Person
#   include Bencoding::Serializable
#
#   @[Bencoding::Field(converter: Time::EpochConverter)]
#   property birth_date : Time
# end
#
# person = Person.bdecode("i1459859781e")
# person.birth_date # => 2016-04-05 12:36:21 UTC
# person.bencode    # => "i1459859781e"
# ```
module Time::EpochConverter
  def self.bencode(value : Time, builder : Bencoding::Builder)
    builder.integer(value.to_unix)
  end
end

# Converter to be used with `Benconding::Field` annotation
# to serialize a `Time` instance as the number of milliseconds
# since the unix epoch. See `Time#to_unix_ms`.
#
# ```
# require "bencoding"
#
# class Timestamp
#   include Bencoding::Serializable
#
#   @[Bencoding::Field(converter: Time::EpochMillisConverter)]
#   property value : Time
# end
#
# timestamp = Timestamp.bdecode("i1459860483856e")
# timestamp.value   # => 2016-04-05 12:48:03.856 UTC
# timestamp.bencode # => "i1459860483856e"
# ```
module Time::EpochMillisConverter
  def self.bencode(value : Time, builder : Bencoding::Builder)
    builder.integer(value.to_unix_ms)
  end
end
