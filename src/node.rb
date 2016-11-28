class Node

  attr_reader :id
  attr_reader :data
  attr_reader :in_edges
  attr_reader :out_edges
  attr_reader :depth

  # 初期化
  # id：ノードのID
  def initialize(id, data)
    @id = id
    @data = data
    @in_edges = []
    @out_edges = []
    @depth = nil
  end

  # 深さを設定
  # depth: 深さ
  def set_depth(depth)
    @depth = depth
  end

  # 表示用
  def inspect
    return "#{data}(id=#{id}):\nins=>#{in_edges}\nouts=>#{out_edges}\n"
  end

end
