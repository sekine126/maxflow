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
    @community = []
  end

  # シードを設定
  # seeds：設定するノードのIDリスト
  def set_seeds(list)
    reset_seeds
    list.each do |l|
      old_size = @seeds.size
      @nodes.each do |node|
        if node.id == l
          @seeds.push(node)
        end
      end
      if @seeds.size == old_size
        puts "ERROR in set_seeds(list): Node in list is not exist."
        puts "list is "
        p list
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
      community << [c.from, c.to]
    end
    return community
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
        edge.flow = 0
        edge.capacity = @seeds.size
      end
    end
  end

  # 仮想始点を追加
  # 仮想始点からシードへ容量無限(65536)のエッジを追加する。
  # 仮想始点のノードIDは-1。
  def set_start
    @start = add_node(-1)
    @seeds.each do |seed|
      connect(@start.id, seed.id, 0, 65536)
    end
  end

  # 仮想終点を追加
  # シードページと仮想始点以外のノードから辺容量１のエッジを追加する。
  def set_final
    @final = add_node(-2)
    nodes = @nodes - @seeds - [@start, @final]
    nodes.each do |node|
      connect(node.id, @final.id, 0, 1)
    end
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
      edge.flow += 1
      if edge.capacity == edge.flow
        @nodes.each do |node|
          if node.id == edge.from
            node.out_edges.delete(edge)
          end
        end
      end
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
      flag = 0
      route.each do |r|
        if edge.to == r.from
          flag = 1
        end
      end
      if flag == 1
        next
      end
      route << edge
      @nodes.each do |node|
        if node.id == edge.to
          if get_free_route(node, route) == 1
            return 1
          else
            route.delete(edge)
          end
        end
      end
    end
    return 0
  end

  # Masflowアルゴリズムを適用したグラフからコミュニティを再帰的に切り離す
  # from：接続元のノード
  # 切り離したコミュニティのエッジ集合を返す。
  def get_community_edges(from)
    from.out_edges.each do |edge|
      if edge.flow >= edge.capacity
        puts "ERROR in get_community_edges: Not free edge in community."
      end
      if @community.size != 0 && @community.include?(edge)
        next
      end
      @community << edge
      @nodes.each do |node|
        if node.id == edge.to
          get_community_edges(node)
        end
      end
    end
  end

end



