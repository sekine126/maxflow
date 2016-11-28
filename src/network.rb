require './src/node.rb'
require './src/edge.rb'
require 'pp'

class Network

  attr_reader :nodes
  attr_reader :edges

  # 初期化
  def initialize
    @serial = 0
    @nodes = []
    @edges = []
    @node_hash = Hash.new()
    @edge_hash = Hash.new()
    @inedge_hash = Hash.new()
    @outedge_hash = Hash.new()
  end

  # エッジを追加
  # from : 接続元ノードの名前
  # to : 接続先ノードの名前
  # capacity：あればエッジの容量
  # エッジに対応するノードがなければ追加する
  # 追加したエッジを返す
  def connect(from_name, to_name, capacity=nil)
    from = check_node(from_name)
    to = check_node(to_name)
    edge = Edge.new(from, to, capacity)
    if @outedge_hash[[from,edge]] == nil
      @nodes[from].out_edges << edge
      @outedge_hash[[from, edge]] = 1
    end
    if @inedge_hash[[to, edge]] == nil
      @nodes[to].in_edges << edge
      @inedge_hash[[to,edge]] = 1
    end
    if @edge_hash[edge] == nil
      @edges << edge
      @edge_hash[edge] = 1
    end
    return edge
  end

  # ノードがあるかチェック
  # data：チェックするノードの名前
  # ノードが存在すればそのIDを返す。
  # ノードが存在しなければ新たに作成してIDを返す。
  def check_node(data)
    if @node_hash[data] == nil
      node = add_node(data)
      @node_hash[data] = node.id
    end
    return @node_hash[data]
  end

  # ノードを追加
  # data：追加するノードの名前
  # 追加したノードを返す。
  def add_node(data)
    id = @serial
    @serial += 1
    @nodes[id] = Node.new(id, data)
  end

  # 複数のノードを追加
  # list：追加するノードの名前リスト
  # 追加するノードがすでにある場合は追加せずに終了する。
  # 追加したノード配列を返す。
  def add_nodes(list)
    nodes = []
    list.each do |l|
      nodes << check_node(l)
    end
    nodes
  end

  # ノードの表示
  def show_nodes()
    pp @nodes
  end

  # 表示用
  def inspect
    return "---\n" + nodes.collect {|v| v.inspect }.join("\n")
  end

end

