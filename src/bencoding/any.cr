struct Bencoding::Any
  alias Type = String | Int64 | Array(Any) | Hash(String, Any)

  getter raw : Type

  delegate to_s, to: raw

  def initialize(@raw : Type)
  end

  def string? : Bool
    @raw.is_a? String
  end

  def integer? : Bool
    @raw.is_a? Int64
  end

  def list? : Bool
    @raw.is_a? Array(Any)
  end

  def dictionary? : Bool
    @raw.is_a? Hash(String, Any)
  end
end
