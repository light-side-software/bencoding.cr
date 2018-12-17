require "../spec_helper"

describe Bencoding do
  it "should decode Bool" do
    Bool.bdecode("i1e").should be_true
    Bool.bdecode("i0e").should be_false
  end

  it "should decode Char" do
    Char.bdecode("i65e").should eq('A')
  end

  it "should decode integer" do
    Int8.bdecode("i#{Int8::MIN}e").should eq(Int8::MIN)
    Int8.bdecode("i#{Int8::MAX}e").should eq(Int8::MAX)

    UInt8.bdecode("i#{UInt8::MIN}e").should eq(UInt8::MIN)
    UInt8.bdecode("i#{UInt8::MAX}e").should eq(UInt8::MAX)

    Int16.bdecode("i#{Int16::MIN}e").should eq(Int16::MIN)
    Int16.bdecode("i#{Int16::MAX}e").should eq(Int16::MAX)

    UInt16.bdecode("i#{UInt16::MIN}e").should eq(UInt16::MIN)
    UInt16.bdecode("i#{UInt16::MAX}e").should eq(UInt16::MAX)

    Int32.bdecode("i#{Int32::MIN}e").should eq(Int32::MIN)
    Int32.bdecode("i#{Int32::MAX}e").should eq(Int32::MAX)

    UInt32.bdecode("i#{UInt32::MIN}e").should eq(UInt32::MIN)
    UInt32.bdecode("i#{UInt32::MAX}e").should eq(UInt32::MAX)

    Int64.bdecode("i#{Int64::MIN}e").should eq(Int64::MIN)
    Int64.bdecode("i#{Int64::MAX}e").should eq(Int64::MAX)

    UInt64.bdecode("i#{UInt64::MIN}e").should eq(UInt64::MIN)
    UInt64.bdecode("i#{UInt64::MAX}e").should eq(UInt64::MAX)
  end

  it "should decode String" do
    "28:Crystal Programming Language".bdecode.should eq("Crystal Programming Language")
    "9:Bencoding".bdecode.should eq("Bencoding")
    "36:áéíóöőúüűÁÉÍÓÖŐÚÜŰ".bdecode.should eq("áéíóöőúüűÁÉÍÓÖŐÚÜŰ")

    String.bdecode("28:Crystal Programming Language").should eq("Crystal Programming Language")
    String.bdecode("9:Bencoding").should eq("Bencoding")
    String.bdecode("36:áéíóöőúüűÁÉÍÓÖŐÚÜŰ").should eq("áéíóöőúüűÁÉÍÓÖŐÚÜŰ")
  end

  it "should decode Array" do
    Array(Int32).bdecode("li1ei2ee").should eq([1, 2])
    Array(String).bdecode("l4:zero3:onee").should eq(%w(zero one))
    Array(Int32 | String).bdecode("li1e3:twoe").should eq([1, "two"])
  end

  it "should decode Set" do
    Set(Int32).bdecode("li1ei2ee").should eq(Set{1, 2})
    Set(String).bdecode("l5:apple6:orangee").should eq(Set{"apple", "orange"})
  end

  it "should decode Hash" do
    Hash(String, Int32).bdecode("d3:onei1e3:twoi2ee").should eq({"one" => 1, "two" => 2})
    Hash(Int32, String).bdecode("di1e3:onei3e5:threee").should eq({1 => "one", 3 => "three"})
    Hash(String, Hash(String, String)).bdecode("d7:optionsd2:bg5:black2:fg5:whiteee").should eq({"options" => {"bg" => "black", "fg" => "white"}})
  end

  it "should decode Tuple" do
    Tuple(Int32, String, Bool).bdecode("li1e3:onei1ee").should eq({1, "one", true})
  end

  it "should decode NamedTuple" do
    NamedTuple(name: String, age: UInt8, uses_crystal: Bool).bdecode("d4:name6:Tamás3:agei30e12:uses_crystali1ee").should eq({name: "Tamás", age: 30_u8, uses_crystal: true})
  end

  it "should decode Enum" do
    Color.bdecode("i0e").should eq(Color::Red)
    Color.bdecode("i1e").should eq(Color::Green)
    Color.bdecode("i2e").should eq(Color::Blue)
  end

  it "should decode Union" do
    (Int32 | String).bdecode("6:string").should eq("string")
    (Int8 | String).bdecode("i15e").should eq(15_i8)
    (Bool | String).bdecode("i1e").should be_true
    (Int32 | Array(Int32)).bdecode("li1ei2ee").should eq([1, 2])
    (Bool | Array(UInt8 | String)).bdecode("li1e3:twoe").should eq([1_u8, "two"])
    (UInt16 | Hash(String, String)).bdecode("d3:one3:egye").should eq({"one" => "egy"})
    (Bool | Hash(String, (String | Bool))).bdecode("d3:onei1ee").should eq({"one" => true})
    (String | Color).bdecode("i1e").should eq(Color::Green)
  end

  it "should decode Time" do
    Time.bdecode("28:2016-02-15T10:20:30+01:00:00").should eq(Time.new(2016, 2, 15, 10, 20, 30, location: Time::Location.load("Europe/Budapest")))
  end
end
