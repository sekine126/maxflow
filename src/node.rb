class Node

  attr_reader :id

  # 初期化
  # id：ノードのID
  def initialize(id)
    @id = id
  end

  # 表示用
  def inspect
    return "id -> #{id}"
  end

end
