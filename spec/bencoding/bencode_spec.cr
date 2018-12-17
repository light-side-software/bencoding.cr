require "../spec_helper"

describe Bencoding do
  it "should encode Bool" do
    true.bencode.should eq("i1e")
    false.bencode.should eq("i0e")
  end

  it "should encode Char" do
    'A'.bencode.should eq("i65e")
  end

  it "should encode integer" do
    0_i8.bencode.should eq("i0e")
    Int8::MIN.bencode.should eq("i#{Int8::MIN}e")
    Int8::MAX.bencode.should eq("i#{Int8::MAX}e")

    UInt8::MIN.bencode.should eq("i#{UInt8::MIN}e")
    UInt8::MAX.bencode.should eq("i#{UInt8::MAX}e")

    0_i16.bencode.should eq("i0e")
    Int16::MIN.bencode.should eq("i#{Int16::MIN}e")
    Int16::MAX.bencode.should eq("i#{Int16::MAX}e")

    UInt16::MIN.bencode.should eq("i#{UInt16::MIN}e")
    UInt16::MAX.bencode.should eq("i#{UInt16::MAX}e")

    0_i32.bencode.should eq("i0e")
    Int32::MIN.bencode.should eq("i#{Int32::MIN}e")
    Int32::MAX.bencode.should eq("i#{Int32::MAX}e")

    UInt32::MIN.bencode.should eq("i#{UInt32::MIN}e")
    UInt32::MAX.bencode.should eq("i#{UInt32::MAX}e")

    0_i64.bencode.should eq("i0e")
    Int64::MIN.bencode.should eq("i#{Int64::MIN}e")
    Int64::MAX.bencode.should eq("i#{Int64::MAX}e")

    UInt64::MIN.bencode.should eq("i#{UInt64::MIN}e")
    UInt64::MAX.bencode.should eq("i#{UInt64::MAX}e")
  end

  it "should encode String" do
    "Crystal Programming Language".bencode.should eq("28:Crystal Programming Language")
    "Bencoding".bencode.should eq("9:Bencoding")
    "áéíóöőúüűÁÉÍÓÖŐÚÜŰ".bencode.should eq("36:áéíóöőúüűÁÉÍÓÖŐÚÜŰ")
  end

  it "should encode Symbol" do
    :crystal.bencode.should eq("7:crystal")
  end

  it "should encode Array" do
    [1, 2].bencode.should eq("li1ei2ee")
    %w(zero one).bencode.should eq("l4:zero3:onee")
  end

  it "should encode Set" do
    Set{1, 2}.bencode.should eq("li1ei2ee")
    Set{:apple, :orange}.bencode.should eq("l5:apple6:orangee")
  end

  it "should encode Hash" do
    {"one" => 1, "two" => 2}.bencode.should eq("d3:onei1e3:twoi2ee")
    {1 => "one", 3 => "three"}.bencode.should eq("di1e3:onei3e5:threee")
    {options: {bg: :black, fg: :white}}.bencode.should eq("d7:optionsd2:bg5:black2:fg5:whiteee")
  end

  it "should encode Tuple" do
    {1, "one", :two}.bencode.should eq("li1e3:one3:twoe")
  end

  it "should encode NamedTuple" do
    {name: "Tamás", role: :dev, age: 30}.bencode.should eq("d4:name6:Tamás4:role3:dev3:agei30ee")
  end

  it "should encode Enum" do
    Color::Red.bencode.should eq("i0e")
    Color::Green.bencode.should eq("i1e")
    Color::Blue.bencode.should eq("i2e")
  end

  it "should encode Time" do
    Time.new(2016, 2, 15, 10, 20, 30, location: Time::Location.load("Europe/Budapest")).bencode.should eq("28:2016-02-15T10:20:30+01:00:00")
  end
end
