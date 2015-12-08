require './src/network.rb'

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
    @depth = 0
    @community = []
    @used = Hash.new(0)
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
        puts "ERROR in set_seeds(ids): Node id=#{id} is not exist."
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
    while flow_free_route == 1
    end
  end

  # Maxflowアルゴリズムで得られたコミュニティを返す
  # ２次元配列[[from,to],[from,to]...]を返す。
  # 仮想始点は-1、仮想終点は-2である。
  def get_community
    community = []
    @community = []
    get_community_edges(@start)
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
    @start = add_node(-1)
    @seeds.each do |seed|
      connect(@start.data, seed.data, 65536)
    end
  end

  # 仮想終点を追加
  # シードページと仮想始点以外のノードから辺容量１のエッジを追加する。
  def set_final
    @final = add_node(-2)
    nodes = @nodes - @seeds - [@start, @final]
    nodes.each do |node|
      connect(node.data, @final.data, 1)
    end
  end

  # 容量に空きがあるルートにフローを最大まで流す
  # フローを流したら１を返し、なければ０を返す
  # 容量が満たされたエッジは削除する
  def flow_free_route
    @route = []
    flag = 0
    while flag == 0
      if @depth > 40
        return 0
      end
      flag = get_free_route(@final,[])
      if flag == 0
        @depth += 1
      end
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
  def get_free_route(to, route)
    if route.size > @depth
      return 0
    end
    free_edges = []
    to.in_edges.each do |edge|
      if @used[edge] < edge.capacity
        flag = 0
        route.each do |r|
          if edge.from == r.to
            flag = 1
          end
        end
        if flag == 1
          next
        end
        free_edges << edge
      end
    end
    free_edges.each do |edge|
      if @seeds.include?(@nodes[edge.from])
        route << edge
        @nodes[edge.from].in_edges.each do |e|
          if e.from == @start.id
            route << edge
            @route = route
            return 1
          end
        end
        free_edges.delete(edge)
      end
    end
    free_edges.each do |edge|
      route << edge
      if get_free_route(@nodes[edge.from], route) == 1
        return 1
      else
        route.delete(edge)
      end
    end
    return 0
  end

  # Masflowアルゴリズムを適用したグラフからコミュニティを再帰的に切り離す
  # from：接続元のノード
  # 切り離したコミュニティのエッジ集合を返す。
  def get_community_edges(from)
    from.out_edges.each do |edge|
      if @used[edge] < edge.capacity
        if @community.size != 0 && @community.include?(edge)
          next
        end
        @community << edge
        get_community_edges(@nodes[edge.to])
      end
    end
  end

end



