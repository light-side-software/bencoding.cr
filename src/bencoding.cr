require "./bencoding/**"

module Bencoding
  VERSION = "0.1.0"

  # b = Builder.new STDOUT
  # b.dictionary do
  #   b.field "numbers" do
  #     b.dictionary do
  #       b.field "one", "egy"
  #       b.field "two", "kettő"
  #     end
  #   end
  # end
  # puts

  # str = String.build do |str|
  #   b = Builder.new str
  #   b.integer 162
  #   b.integer 5162
  # end
  # puts "str=#{str}\n"

  # p = Parser.new IO::Memory.new(str)
  # i = p.read_u8
  # puts "i = #{i} : #{i.class}"
  # i = p.read_i32
  # puts "i = #{i} : #{i.class}"

  # puts "\n\n"
  # str = "3:one"
  # p = Parser.new IO::Memory.new(str)
  # s = p.read_string
  # puts "s = #{s}"

  str = "3:one"
  p = Parser.new IO::Memory.new(str)
  s = p.read_any
  puts "s = #{s} : #{s.class} [#{s.raw.class}]"
  pp s.string?

  class Point
    include Bencoding::Serializable::Hash

    @[Bencoding::Field]
    property x : Int32 = 0

    @[Bencoding::Field]
    property y : Int32 = 0

    def initialize(@x : Int32 = 0, @y : Int32 = 0)
    end
  end

  class Params
    include Bencoding::Serializable::List

    @[Bencoding::Field]
    property first : Int32 = 0

    @[Bencoding::Field]
    property second : Int32 = 0

    def initialize(@first : Int32 = 0, @second : Int32 = 0)
    end
  end

  class Line
    include Bencoding::Serializable

    @[Bencoding::Field]
    property s : Point

    @[Bencoding::Field]
    property e : Point

    @[Bencoding::Field]
    property p : Params

    def initialize(@s : Point, @e : Point, @p : Params = Params.new(200, 100))
    end
  end

  # l = Line.new(Point.new(131, 614), Point.new(155, 81))
  # encoded = l.bencode
  # p encoded

  # d = Line.new(Bencoding::Parser.new(IO::Memory.new(encoded)))
  # pp d

  # parser = Parser.new(IO::Memory.new("3:one"))
  # str = String.new(parser)
  # pp str
  parser = Parser.new(IO::Memory.new("i52e"))
  pp Int8.new(parser)
end
