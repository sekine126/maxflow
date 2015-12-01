class Node

  attr_reader :id
  attr_reader :data
  attr_reader :in_edges
  attr_reader :out_edges

  # 初期化
  # id：ノードのID
  def initialize(id, data)
    @id = id
    @data = data
    @in_edges = []
    @out_edges = []
  end

  # 表示用
  def inspect
    return "#{data}(id=#{id}):\nins=>#{in_edges}\nouts=>#{out_edges}\n"
  end

end
