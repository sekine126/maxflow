
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

# コミュニティデータをファイルから取得
db_name = params["d"]
date1 = params["f"]
date2 = params["t"]
nodes1 = []
nodes2 = []
links1 = []
links2 = []
nodes1_hash = Hash.new()
nodes2_hash = Hash.new()
links1_hash = Hash.new()
links2_hash = Hash.new()
link1_filename = "./data/crawl/#{db_name}_crawl_#{date1}.txt"
link2_filename = "./data/update/bet_#{db_name}_#{date1}_#{date2}.txt"

# 初期コミュニティデータ
open(link1_filename) {|file|
  while l = file.gets
    links1 << l.chomp
    nodes1 << l.split(",")[0].to_i
    nodes1 << l.split(",")[1].to_i
    links1_hash[l.chomp] = 1
    nodes1_hash[l.split(",")[0].to_i] = 1
    nodes1_hash[l.split(",")[1].to_i] = 1
  end
}
nodes1.uniq!
links1.uniq!

# 指定した日付の局所クロールで更新したコミュニティデータ
open(link2_filename) {|file|
  while l = file.gets
    links2 << l.chomp
    nodes2 << l.split(",")[0].to_i
    nodes2 << l.split(",")[1].to_i
    links2_hash[l.chomp] = 1
    nodes2_hash[l.split(",")[0].to_i] = 1
    nodes2_hash[l.split(",")[1].to_i] = 1
  end
}
nodes2.uniq!
links2.uniq!

# 初期コミュニティから新しく追加されたページを抽出
new_nodes = []
new_nodes_hash = Hash.new()
nodes2.each do |node2|
  if nodes1_hash[node2] == nil
    new_nodes << node2
    new_nodes_hash[node2] = 1
  end
end
new_nodes.uniq!
puts "nodes1 = #{nodes1.size}, nodes2 = #{nodes2.size}, new node = #{new_nodes.size}"

# ハブスコアランキングファイルから新しく追加されたページだけを抽出
bet_filename = "./data/R/bet_#{params["d"]}_#{params["t"]}.txt"
ids_filename = "./data/matrix/bet_ids_#{params["d"]}_#{params["t"]}.txt"
new_page_rank = []
hashs = Hash.new()
open(ids_filename) {|file|
  while l = file.gets
    l.chomp!
    hashs[l.split(",")[0].to_i] = l.split(",")[1].to_i
  end
}
scores = []
open(bet_filename) {|file|
  while l = file.gets
    l.chomp!
    l.strip!
    id = l.split(",")[0].to_i
    scores << [id, l.split(",")[1]]
  end
}
scores.sort! { |a, b| b[1] <=> a[1] }
scores.each do |score|
  if new_nodes_hash[hashs[score[0]]] == 1
    new_page_rank << "#{hashs[score[0]]},#{score[1]}"
  end
end

# 結果をファイル出力
if new_page_rank == nil
  puts "New page not found."
else
  file = File.open("./data/new_rank/bet_#{params["d"]}_#{params["t"]}.txt", "w")
  file.puts("# #{new_page_rank.size} Page")
  new_page_rank.each do |new_page|
    file.puts(new_page)
  end
  file.close
end

