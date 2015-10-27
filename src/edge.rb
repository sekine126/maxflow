class Edge

  attr_reader :to
  attr_reader :from
  attr_accessor :flow
  attr_accessor :capacity

  # 初期化
  # from：接続元ノードのID
  # to：接続先ノードのID
  # capacity：あればエッジの容量
  # flow：あればエッジに流れるフロー
  def initialize(from, to, flow=nil, capacity=nil)
    @from = from
    @to = to
    @flow = flow
    @capacity = capacity
  end

  # 表示用
  def inspect
    return "#{from} -> #{to} : #{flow} / #{capacity}"
  end

end
