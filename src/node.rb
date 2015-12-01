class Node

  attr_reader :id
  attr_reader :in_edges
  attr_reader :out_edges

  # 初期化
  # id：ノードのID
  def initialize(id)
    @id = id
    @in_edges = []
    @out_edges = []
  end

  # 表示用
  def inspect
    return "id -> #{@id}, in.size -> #{@in_edges.size}, out.size -> #{@out_edges.size}"
  end

end
