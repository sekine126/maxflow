require './src/node.rb'
require './src/edge.rb'

class Network

  attr_reader :nodes
  attr_reader :edges

  # 初期化
  def initialize
    @nodes = []
    @edges = []
  end

  # エッジを追加
  # from : 接続元ノードのID
  # to : 接続先ノードのID
  # flow：あればエッジに流れるフロー
  # capacity：あればエッジの容量
  # 追加したエッジを返す
  # エッジに対応するノードがなければ追加する
  def connect(from, to, flow=nil, capacity=nil)
    e = Edge.new(from, to, flow, capacity)
    from_node = add_node(from)
    from_node.out_edges << e
    to_node = add_node(to)
    to_node.in_edges << e
    @edges << e
    e
  end

  # ノードを追加
  # id：追加するノードのID
  # 追加するノードがすでにある場合は追加せずに終了する。
  # 追加したノードを返す。
  def add_node(id)
    @nodes.each do |node|
      if node.id == id
        return node
      end
    end
    n = Node.new(id)
    @nodes << n
    n
  end

  # 複数のノードを追加
  # ids：追加するノードのIDのリスト
  # 追加するノードがすでにある場合は追加せずに終了する。
  def add_nodes(ids)
    nodes = []
    ids.each do |id|
      nodes << add_node(id)
    end
    nodes
  end

  # 表示用
  def inspect
    return "---\n" + nodes.collect {|v| v.inspect }.join("\n")
  end

end

