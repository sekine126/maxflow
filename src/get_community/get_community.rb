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
when "nari"
  seeds = [3661182180,4057245323,1475246837,2542153585,1051572582]
when "ff"
  seeds = [3894709485,628479943,942513496,1094811195,121489093]
when "paku"
  seeds = [3711160862,213369117,938368568,326510609,843038910]
when "poke"
  seeds = [2636383170,3404738092,3585790867,1956461567,4236230510]
when "koike"
  seeds = [49470735,1040685745,973848669,741763480]
when "yugi"
  seeds = [3763176140,1167275457,3428069626,2726311626,879344731]
when "siro"
  seeds = [2514769485,1483246303,705928223,4042273440,1532084318]
when "grab"
  seeds = [2754764568,4020409988,407883683,1213261361,1856085666]
when "fgo"
  seeds = [831545392,909676878,920136267,3925881401,3238855749]
when "shad"
  seeds = [1174678884,2557919238,3588114368,2661212247,3294955]
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
    links.push([row["from_url_crc"].to_i, row["to_url_crc"].to_i])
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

