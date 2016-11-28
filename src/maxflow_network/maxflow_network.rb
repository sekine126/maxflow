require './src/maxflow_network/network.rb'

class MaxflowNetwork < Network

  attr_reader :seeds
  attr_reader :start
  attr_reader :final
  attr_reader :route
  attr_reader :community

  # 初期化
  def initialize
    super
    @seeds = []
    @start = nil
    @final = nil
    @route = []
    @community = []
    @used = Hash.new(0)
    @deadlock_nodes = Hash.new()
    @size = 0
  end

  # シードを設定
  # seeds：設定するノードの名前リスト
  def set_seeds(list)
    reset_seeds
    list.each do |data|
      old_size = @seeds.size
      @nodes.each do |node|
        if node.data == data
          @seeds << node
        end
      end
      if @seeds.size == old_size
        puts "ERROR in set_seeds(ids): not exist."
        exit(1)
      end
    end
  end

  # Maxflowアルゴリズム
  # 辺容量の限界までflowを流す。
  def maxflow
    init_edge
    set_start
    set_final
    set_depth
    num = 0
    print "\rflow start: #{num} route."
    while flow_free_route == 1
      num += 1
      print "\rflow start: #{num} route."
    end
    puts ""
  end

  # Maxflowアルゴリズムで得られたコミュニティを返す
  # ２次元配列[[from,to],[from,to]...]を返す。
  # 仮想始点は-1、仮想終点は-2である。
  def get_community
    community = []
    @community = []
    @deadlock_nodes = Hash.new()
    get_community_edges(@start)
    puts ""
    @community.each do |c|
      community << [@nodes[c.from].data, @nodes[c.to].data]
    end
    return community
  end

  def used(edge)
    @used[edge]
  end

  private

  # シードをリセット
  def reset_seeds
    @seeds = []
  end

  # エッジの初期化
  # 仮想点を含まないエッジの容量をすべてシードの数にする。
  def init_edge
    @nodes.each do |node|
      node.out_edges.each do |edge|
        edge.capacity = @seeds.size
      end
      node.in_edges.each do |edge|
        edge.capacity = @seeds.size
      end
    end
  end

  # 仮想始点を追加
  # 仮想始点からシードへ容量無限(65536)のエッジを追加する。
  # 仮想始点のノード名は-1。
  def set_start
    @start = @nodes[check_node(-1)]
    @seeds.each do |seed|
      connect(@start.data, seed.data, 65536)
    end
  end

  # 仮想終点を追加
  # シードページと仮想始点以外のノードから辺容量１のエッジを追加する。
  def set_final
    @final = @nodes[check_node(-2)]
    nodes = @nodes - @seeds - [@start, @final]
    nodes.each_with_index do |node, i|
      print "\rset final start: #{i+1}/#{nodes.size}"
      connect(node.data, @final.data, 1)
    end
    puts ""
  end

  # 容量に空きがあるルートにフローを最大まで流す
  # フローを流したら１を返し、なければ０を返す
  # 容量が満たされたエッジは削除する
  def flow_free_route
    @route = []
    if get_free_route(@start,[]) == 0
      return 0
    end
    if @route.size == 0
      puts "ERROR in flow_free_route: @route is empty!"
      exit(1)
    end
    @route.each do |edge|
      @used[edge] += 1
    end
    return 1
  end

  # 容量に空きのあるルートを再帰的に探す
  # from：接続元のノード
  # 空きのあるルートが見つかれば、そのエッジ集合を返す
  # 空きのあるルートが見つからなければ、nilを返す
  def get_free_route(from, route)
    if from == @final
      @route = route
      return 1
    end
    from.out_edges.each do |edge|
      if @deadlock_nodes[@nodes[edge.to]] == nil && @used[edge] < edge.capacity
        next if route.any?{|r| edge.to == r.from}
        route << edge
        # 追加 
        if get_free_route(@nodes[edge.to], route) == 1
          return 1
        else
          route.delete(edge)
        end
      end
    end
    @deadlock_nodes[from] = 1
    return 0
  end

  # Maxflowアルゴリズムを適用したグラフからコミュニティを再帰的に切り離す
  # from：接続元のノード
  # 切り離したコミュニティのエッジ集合を返す。
  def get_community_edges(from)
    @deadlock_nodes[from] = 1
    from.out_edges.each do |edge|
      if !@community.include?(edge) && @used[edge] < edge.capacity
        @community << edge
        if @deadlock_nodes[@nodes[edge.to]] == nil
          get_community_edges(@nodes[edge.to])
          @size += 1
          print "\rnodes #{@size}"
        end
      end
    end
  end

  # 深度を設定する関数
  # startノードは0
  # finalノードは4
  def set_depth
    @seeds.each do |seed|
      seed.set_depth(1)
      seed.out_edges.each do |edge|
        @nodes[edge.to].set_depth(2)
      end
    end
    @nodes.each do |node|
      if node == @start
        node.set_depth(0)
        next
      end
      if node == @final
        node.set_depth(4)
        next
      end
      if node.depth == nil
        node.set_depth(3)
      end
    end
  end

end


