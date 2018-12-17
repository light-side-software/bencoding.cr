require "./spec_helper"

enum Color
  Red
  Green
  Blue
end

struct Point
  include Bencoding::Serializable

  property x : Int32 = 0
  property y : Int32 = 0

  def initialize(@x : Int32 = 0, @y : Int32 = 0)
  end
end

alias Polygon = Array(Point)

struct Line
  include Bencoding::Serializable::List

  property start : Point = Point.new
  property _end : Point = Point.new

  @[Bencoding::Field(ignore: true)]
  getter calculated : Float64 = 0.0

  def initialize(@start : Point = Point.new, @_end : Point = Point.new)
    @calculated = @start.x.to_f + @start.y.to_f
  end
end

class Address
  include Bencoding::Serializable::Dictionary

  @[Bencoding::Field(key: "co")]
  property country : String = ""

  @[Bencoding::Field(key: "ci")]
  property city : String = ""

  @[Bencoding::Field(key: "st")]
  property street : String = ""

  @[Bencoding::Field(key: "po")]
  property postal : UInt16 = 0

  def initialize(@country : String = "", @city : String = "", @street : String = "", @postal : UInt16 = 0)
  end
end

class Person
  include Bencoding::Serializable::Dictionary

  property name : String = ""
  property age : UInt8 = 0

  @[Bencoding::Field(key: "addr")]
  property address : Address = Address.new

  def initialize(@name : STring = "", @age : UInt8 = 0, @address : Address = Address.new)
  end
end

class Employee < Person
  include Bencoding::Serializable::Dictionary

  property company : String = ""
  property job : String = ""

  def initialize(@company : String = "", @job : String = "")
  end
end
