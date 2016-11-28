require 'pp'

params = ARGV.getopts('d:f:')
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

# コミュニティデータをファイルから取得
db_name = params["d"]
link_date = params["f"]
link_filename = "./data/update/hits_update_#{db_name}_#{link_date}.txt"
nodes = []
links = []
# 初期データ
open(link_filename) {|file|
  while l = file.gets
    # 仮想始点からのリンクは除く
    next if l.chomp[0] == "-"
    links << l.chomp
    l.split(",").each do |h|
      nodes << h.to_i
    end
  end
}
nodes.uniq!

# 隣接行列を作成
matrix = Array.new(nodes.size).map{Array.new(nodes.size,0)}
links.each { |link| 
  from = link.split(",")[0].to_i
  to = link.split(",")[1].to_i
  from_id = nodes.find_index(from)
  to_id = nodes.find_index(to)
  matrix[from_id][to_id] = 1
}

# 行列の長さを画面に出力
puts "Matrix #{nodes.size} length."

# 計算結果用のIDリストをファイルに出力
file = File.open("./data/matrix/hits_ids_#{params["d"]}_#{params["f"]}.txt", "w")
nodes.each_with_index do |node, id|
  line = "#{id+1},#{node.to_i}"
  file.puts(line)
end
file.close

# 計算結果の隣接行列をファイルに出力
file = File.open("./data/matrix/hits_#{params["d"]}_#{params["f"]}.txt", "w")
matrix.each { |row| 
  line = ""
  row.each { |v| 
    line = line + "#{v} "
  }
  file.puts(line)
}
file.close
