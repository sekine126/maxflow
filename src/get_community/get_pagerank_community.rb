require './src/maxflow_network/maxflow_network.rb'
require 'mysql2'

params = ARGV.getopts('d:f:t:')
if params["d"] == nil
  puts "Error: Please set -d database name."
  exit(1)
end
if params["f"] == nil
  puts "Error: Please set -f date option."
  exit(1)
end
if params["f"] != nil && params["f"].size != 8 
  puts "Error: -f is date. e.g. 20150214"
  exit(1)
end
if params["t"] == nil
  puts "Error: Please set -t date option."
  exit(1)
end
if params["t"] != nil && params["f"].size != 8 
  puts "Error: -t is date. e.g. 20150214"
  exit(1)
end

# 初期コミュニティをファイルから取得
puts "Load First community."
data_filename = "./data/crawl/#{params["d"]}_crawl_#{params["f"]}.txt"
first_links = []
first_nodes = []
open(data_filename) {|file|
  while l = file.gets
    first_links << l.chomp
    l.split(",").each do |h|
      first_nodes << h.chomp
    end
  end
}
first_nodes.uniq!
puts "first community #{first_nodes.size} nodes."
puts "first community #{first_links.size} links."

# シードリスト
puts "Get seed list."
seeds = []
first_links.each do |flink|
  if flink.split(",")[0] == "-1"
    seeds << flink.split(",")[1].to_i
  end
end

# mysqlの設定
db_name = "#{params["d"]}_crawl"
client = Mysql2::Client.new(:host => 'localhost', :username => 'root', :password => 'root', :database => db_name)

# リンクリストをDBから取得
links1 = []
nodes1 = []
links2 = []
nodes2 = []
num = 0
seeds.each do |seed|
  num += 1
  if db_name == "koike_crawl" && num == 3
    num += 1
  end
  # 初期データを取得
  query = "select from_url_crc, to_url_crc from link#{num}_#{params["f"]}"
  results = client.query(query)
  results.each do |row|
    links1.push([row["from_url_crc"].to_i, row["to_url_crc"].to_i])
    nodes1 << row["from_url_crc"].to_i
    nodes1 << row["to_url_crc"].to_i
  end
  # 更新する対象のある日時のデータを取得
  query = "select from_url_crc, to_url_crc from link#{num}_#{params["t"]}"
  results = client.query(query)
  results.each do |row|
    links2.push([row["from_url_crc"].to_i, row["to_url_crc"].to_i])
    nodes2 << row["from_url_crc"].to_i
    nodes2 << row["to_url_crc"].to_i
  end
end
nodes1.uniq!
nodes2.uniq!
links1.uniq!
links2.uniq!

# 更新対象のページリストを作成
update_pages = []
# Pagerankでランキング付してWebコミュニティの上位2割を取得する
pagerank_filename = "./data/R/prank_#{params["d"]}_#{params["f"]}.txt"
ids = []
first_nodes.delete("-1")
pagerank_values = []
open(pagerank_filename) {|file|
  while l = file.gets
    l.chomp!
    l.strip!
    pagerank_values << l.split(",")[1].to_f
  end
}
sort_pagerank_values = pagerank_values.sort {|a, b| b <=> a }
sort_pagerank_values.each do |sbvalue|
  id = pagerank_values.find_index(sbvalue)
  ids << id + 1
  pagerank_values[id] = -1
end
ids = ids[0..((ids.size*0.2) - 1).ceil]
ids_filename = "./data/matrix/ids_#{params["d"]}_#{params["f"]}.txt"
open(ids_filename) {|file|
  while l = file.gets
    l.chomp!
    if ids.include?(l.split(",")[0].to_i)
      update_pages << l.split(",")[1].to_i
    end
  end
}
# 重複を削除
update_pages.uniq!
# シードページのリンク先で初期データにない新しいページを加える
update_pages.each do |upage|
  # 更新対象のページがシードページの場合
  if seeds.include?(upage)
    out_nodes = []
    # 新しくクロールしてきたデータからリンク先を取得
    links2.each do |link2|
      if link2[0] == upage
        out_nodes << link2[1]
      end
    end
    # リンク先の中で初期データにないものを新たに更新対象のページに加える
    out_nodes.each do |onode|
      if !(nodes1.include?(onode))
        update_pages << onode
      end
    end
  end
end
# 重複を削除
update_pages.uniq!

# 新たにクロールする必要のあるノードリスト
crawled_nodes = []
update_pages.each do |upage|
  crawled_nodes << upage
end

# 更新対象のリンクリスト
updated_links = []
# 元データから更新対象以外のページのリンク情報を保存
links1.each do |link1|
  if !(update_pages.include?(link1[0]))
    updated_links << link1
  end
end
# 更新対象のページの場合は新しくクロールしてきたデータを使う
links2.each do |link2|
  if update_pages.include?(link2[0])
    updated_links << link2
    # 新たにクロールする必要があるノードのため加える
    crawled_nodes << link2[1]
  end
end

# 更新するのに必要なクロール数を表示
crawled_nodes.uniq!
puts "Update nessesary #{crawled_nodes.size} crawl."
puts "Reduce crawl nessesary #{100-((crawled_nodes.size/(nodes2.size - 1).to_f)*100).round(2)}"

m = MaxflowNetwork.new

# リンクを作成
puts "#{updated_links.size} connect start."
updated_links.each do |d|
  m.connect(d[0],d[1])
end

# ノード数を記録
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
puts "Total #{num_nodes}node."
puts "Total #{updated_links.size} links"
puts "Get community total #{com_nodes.size}nodes."
puts "Get community total #{community.size}links."

# 結果をファイル出力
file = File.open("./data/update/prank_#{params["d"]}_#{params["f"]}_#{params["t"]}.txt", "w")
community.each do |link|
  file.puts("#{link[0]},#{link[1]}")
end
file.close

