require "./parser"

def Object.bdecode(io : IO) : self
  new Bencoding::Parser.new(io)
end

def Object.bdecode(string : String) : self
  bdecode(IO::Memory.new(string))
end

def Bool.new(parser : Bencoding::Parser)
  parser.read_i32 > 0 ? true : false
end

def Char.new(parser : Bencoding::Parser)
  parser.read_i32.chr
end

{% for type in %w(Int8 Int16 Int32 Int64 UInt8 UInt16 UInt32) %}
  def {{type.id}}.new(parser : Bencoding::Parser)
    {{type.id}}.new(parser.read_i64)
  end
{% end %}

def UInt64.new(parser : Bencoding::Parser)
  parser.read_u64
end

class String
  def self.new(parser : Bencoding::Parser)
    parser.read_string
  end

  def bdecode : self
    String.bdecode(self)
  end
end

def Array.new(parser : Bencoding::Parser)
  parser.read_list(T)
end

def Set.new(parser : Bencoding::Parser)
  new parser.read_list(T)
end

def Hash.new(parser : Bencoding::Parser)
  parser.read_dictionary(K, V)
end

def Tuple.new(parser : Bencoding::Parser)
  {% begin %}
    parser.read_begin_list
    value = Tuple.new(
      {% for i in 0...T.size %}
        (self[{{i}}].new(parser)),
      {% end %}
    )
    parser.read_end_list
    value
  {% end %}
end

def NamedTuple.new(parser : Bencoding::Parser)
  {% begin %}
    parser.read_begin_dictionary
    value = {
      {% for key, type in T %}
        {{key}}: begin
          k = String.new(parser)
          if {{key.stringify}} != k
            raise "parse error"
          end
          {{type}}.new(parser)
        end,
      {% end %}
    }
    parser.read_end_dictionary
    value
  {% end %}
end

def Enum.new(parser : Bencoding::Parser)
  case parser.next_kind
  when :integer
    from_value(parser.read_i64)
  when :string
    parse(parser.read_string)
  else
    raise "Expecting int or string in Bencoding for #{self.class}"
  end
end

def Union.new(parser : Bencoding::Parser)
  case parser.next_kind
  when :integer
    {% if T.includes?(Int64) %}
      return parser.read_i64
    {% end%}
    {% if T.includes?(UInt64) %}
      return parser.read_u64
    {% end%}
    {% if T.includes?(Int32) %}
      return parser.read_i32
    {% end%}
    {% if T.includes?(UInt32) %}
      return parser.read_u32
    {% end%}
    {% if T.includes?(Int16) %}
      return parser.read_i16
    {% end%}
    {% if T.includes?(UInt16) %}
      return parser.read_u16
    {% end%}
    {% if T.includes?(Int8) %}
      return parser.read_i8
    {% end%}
    {% if T.includes?(UInt8) %}
      return parser.read_u8
    {% end%}
    {% if T.includes?(Char) %}
      return parser.read_i32.chr
    {% end%}
    {% if T.includes?(Bool) %}
      return Bool.new(parser)
    {% end%}
    {% for type, index in T %}
      {% if type < Enum %}
      begin
        return parser.try_read do
          {{type.id}}.new(parser)
        end
      rescue
        # Ignore
      end
      {% end %}
    {% end %}
    raise "parse error"
  when :string
    {% if T.includes?(String) %}
      return parser.read_string
    {% end%}
    raise "parse error"
  when :list
    {% for type, index in T %}
      {% if type < Array %}
      begin
        return parser.try_read do
          parser.read_list({{type.type_vars.first}})
        end
      rescue
        # Ignore
      end
      {% end %}
    {% end %}
    raise "parse error"
  when :dictionary
    {% for type, index in T %}
      {% if type < Hash %}
      begin
        return parser.try_read do
          parser.read_dictionary({{type.type_vars.first}}, {{type.type_vars[1]}})
        end
      rescue
        # Ignore
      end
      {% end %}
    {% end %}
    raise "parse error"
  else
    {% for type, index in T %}
      {% if !(type < Array) && !(type < Hash) %}
      begin
        return parser.try_read do
          {{type.id}}.new(parser)
        end
      rescue
        # Ignore
      end
      {% end %}
    {% end %}
    raise "parse error"
  end
end

# Reads a string from parser as a time formated according to [RFC 3339](https://tools.ietf.org/html/rfc3339)
# or other variations of [ISO 8601](http://xml.coverpages.org/ISO-FDIS-8601.pdf).
#
# The Bencoding format itself does not specify a time data type, this method just
# assumes that a string holding a ISO 8601 time format can be interpreted as a
# time value.
#
# See `#bencode` for reference.
def Time.new(parser : Bencoding::Parser)
  Time::Format::ISO_8601_DATE_TIME.parse(parser.read_string)
end
