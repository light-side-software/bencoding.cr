require "./any"

class Bencoding::Parser
  def initialize(@io : IO)
  end

  def read_string : String
    size = @io.gets(delimiter: ':', chomp: true).not_nil!.to_i32
    if size == 0
      ""
    else
      str = @io.gets(limit: size).not_nil!
      if str.bytesize != size
        raise "parse error"
      end
      str
    end
  end

  private macro def_read_int(n, t)
    def read_{{n}} : {{t}}
      if @io.read_char == 'i'
        s = @io.gets(delimiter: 'e', chomp: true)
        s.not_nil!.to_{{n}}
      else
        raise "parse error"
      end
    end
  end

  def_read_int i8, Int8
  def_read_int u8, UInt8
  def_read_int i16, Int16
  def_read_int u16, UInt16
  def_read_int i32, Int32
  def_read_int u32, UInt32
  def_read_int i64, Int64
  def_read_int u64, UInt64

  def read_end
    if @io.read_char != 'e'
      raise "parse error"
    end
  end

  def read_begin_list
    if @io.read_char != 'l'
      raise "parse error"
    end
  end

  def read_end_list
    read_end
  end

  def read_list : Array(Any)
    read_begin_list
    arr = [] of Any
    loop do
      break if ['e', '\0', nil].includes?(next_char)
      arr << read_any
    end
    read_end_list
    arr
  end

  def read_list(element_type : T.class) : Array(T) forall T
    read_begin_list
    ary = [] of T
    loop do
      break if ['e', '\0', nil].includes?(next_char)
      ary << T.bdecode(@io)
    end
    read_end_list
    ary
  end

  def read_begin_dictionary
    if @io.read_char != 'd'
      raise "parse error"
    end
  end

  def read_end_dictionary
    read_end
  end

  def read_dictionary : Hash(String, Any)
    read_begin_dictionary
    h = {} of String => Any
    loop do
      break if ['e', '\0', nil].includes?(next_char)
      key = read_string
      value = read_any
      h[key] = value
    end
    read_end_dictionary
    h
  end

  def read_dictionary(key_type : K.class, value_type : V.class) : Hash(K, V) forall K, V
    read_begin_dictionary
    h = {} of K => V
    loop do
      break if ['e', '\0', nil].includes?(next_char)
      key = K.new(self)
      value = V.new(self)
      h[key] = value
    end
    read_end_dictionary
    h
  end

  def read_any : Any
    ch = next_char.not_nil!
    case ch
      when .ascii_number? then Any.new(read_string)
      when 'i' then Any.new(read_i64)
      when 'l' then Any.new(read_list)
      when 'd' then Any.new(read_dictionary)
      else
        raise "parse error"
    end
  end

  def next_kind
    ch = next_char
    return :end if ch.is_a? Nil
    case ch.not_nil!
      when .ascii_number? then :string
      when 'i' then :integer
      when 'l' then :list
      when 'd' then :dictionary
      when '\0' then :end
    else
      :unknown
    end
  end

  def try_read
    pos = @io.pos
    begin
      return yield
    rescue ex
      @io.pos = pos
      raise ex
    end
  end

  private def next_char : Char?
    ch = @io.read_char
    @io.seek(-1, IO::Seek::Current)
    ch
  end
end
