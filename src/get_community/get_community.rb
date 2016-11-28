require './src/maxflow_network/maxflow_network.rb'
require 'mysql2'

params = ARGV.getopts('d:f:')
if params["f"] == nil
  puts "Error: Please set -f date option."
  exit(1)
end
if params["f"] != nil && params["f"].size != 8 
  puts "Error: -f is date. e.g. 20150214"
  exit(1)
end
if params["d"] == nil
  puts "Error: Please set -d db name option."
  exit(1)
end


# 設定しなければいけない部分
db_name = params["d"] + "_crawl"
case params["d"]
when "hakata"
  seeds = [2961957552,2857931423,3111027217,3137023412,514088129]
when "jingu"
  seeds = [3886018716,2646761232,1777038009,436928799,3958544485]
when "amerika"
  seeds = [1120797223,1421490816,3184159479,3681345396,2692437139]
when "kimi"
  seeds = [2458051403,1194505592,4102366185,845947651,198942884]
when "fate"
  seeds = [745547696,554345455,2584108472,725677619,252732281]
else 
  puts "Error: Please set seeds in get_community.rb"
  exit(1)
end


# mysqlの設定
client = Mysql2::Client.new(:host => 'localhost', :username => 'root', :password => 'root', :database => db_name)

# データの準備
links = []
list = []
# シード別のクロールしたリンク数
link_nums = []

# DBからリンク情報を取得
num = 0
seeds.each do |seed|
  num += 1
  # link数字を使っていない場合随時変更
  query = "select from_url_crc, to_url_crc from link#{num}_#{params["f"]}"
  results = client.query(query)
  count = 0
  results.each do |row|
    links.push([row["from_url_crc"], row["to_url_crc"]])
    count += 1
  end
  link_nums << count
end
# 重複リンクを削除
links.uniq!

m = MaxflowNetwork.new

# リンクを作成
puts "#{links.size} connect start."
links.each_with_index {|link, i|
  print "\r#{(100.0*i/links.size).round}% complete";
  m.connect(link[0],link[1])
}
puts ""

# ノード数を記録（ここで記録しないと仮想点が含まれてしまう）
num_nodes = m.nodes.size

# シードを設定
puts "set_seeds start."
m.set_seeds(seeds)

# 実行開始
puts "maxflow start."
m.maxflow
puts "get_community start."
community = m.get_community
com_nodes = []
community.each do |link|
  com_nodes << link[0]
  com_nodes << link[1]
end
com_nodes.uniq!

# 結果を画面表示
#pp community
puts "Total #{num_nodes} node crawled."
link_nums.each_with_index {|lnum, id| 
  puts "seed#{id+1} #{lnum}links crawled."
}
puts "Total #{links.size} links"
puts "Get total #{com_nodes.size} nodes in community."
puts "Get total #{community.size} links in community."

# 結果をファイル出力
file = File.open("./data/crawl/#{db_name}_#{params["f"]}.txt", "w")
community.each do |link|
  file.puts("#{link[0]},#{link[1]}")
end
file.close

