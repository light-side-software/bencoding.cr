class Bencoding::Builder
  def initialize(@io : IO)
  end

  def string(value)
    string = value.to_s
    size = string.bytesize
    @io << size.to_s << ':'
    @io << string if size > 0
  end

  def integer(value : Int)
    @io << 'i' << value.to_s << 'e'
  end

  def list(&block)
    @io << 'l'
    yield.tap { @io << 'e' }
  end

  def dictionary(&block)
    @io << 'd'
    yield.tap { @io << 'e' }
  end

  def field(name, value)
    name.bencode(self)
    case value
      when String, Symbol
        string(value)
      when Int
        integer(value)
      else
        raise "error"
    end
  end

  def field(name)
    name.bencode(self)
    yield
  end

  def flush
    @io.flush
  end
end
