class Node

  attr_reader :id
  attr_reader :in_edges
  attr_reader :out_edges

  # 初期化
  # id：ノードのID
  def initialize(id)
    @id = id
    @out_edges = []
  end

end
