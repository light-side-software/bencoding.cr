require "../spec_helper"

describe Bencoding::Serializable do
  it "should encode struct" do
    Point.new(15, 21).bencode.should eq("i15ei21e")
  end

  it "should decode struct" do
    Point.bdecode("i15ei21e").should eq(Point.new(15, 21))
  end

  it "should encode array" do
    [Point.new(34, 16), Point.new(721, 10)].as(Polygon).bencode.should eq("li34ei16ei721ei10ee")
  end

  it "should decode array" do
    Polygon.bdecode("li34ei16ei721ei10ee").should eq([Point.new(34, 16), Point.new(721, 10)])
  end

  it "should encode nested structs to list" do
    Line.new(Point.new(10, 11), Point.new(23, 27)).bencode.should eq("li10ei11ei23ei27ee")
  end

  it "should decode nested struct from list" do
    line = Line.bdecode("li10ei11ei23ei27ee")
    expected = Line.new(Point.new(10, 11), Point.new(23, 27))

    line.start.should eq(expected.start)
    line._end.should eq(expected._end)
  end

  it "should encode with annotated keys" do
    Address.new(
      country: "Hungary",
      city: "Budapest",
      street: "Hosszú",
      postal: 1000,
    ).bencode.should eq("d2:co7:Hungary2:ci8:Budapest2:st7:Hosszú2:poi1000ee")
  end

  it "should decode with annotated keys" do
    address = Address.bdecode("d2:co7:Hungary2:ci8:Budapest2:st7:Hosszú2:poi1000ee")
    expected = Address.new(
      country: "Hungary",
      city: "Budapest",
      street: "Hosszú",
      postal: 1000)

    address.country.should eq(expected.country)
    address.city.should eq(expected.city)
    address.street.should eq(expected.street)
    address.postal.should eq(expected.postal)
  end
end
