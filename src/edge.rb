class Edge

  attr_reader :to
  attr_reader :from
  attr_accessor :capacity

  # 初期化
  # to：接続先ノードのID
  # from：接続元ノードのID
  # capacity：あればエッジの容量
  def initialize(from, to, capacity=nil)
    @from = from
    @to = to
    @capacity = capacity
  end

  # 表示用
  def inspect
    return "#{from} -> #{to} : #{capacity}"
  end

end
