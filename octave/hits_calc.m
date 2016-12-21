% HITSは、n行n列の隣接行列Lに対して、x0（行ベクトル）を
%   初期ベクトルとしてHITS権威ベクトルxとハブベクトルy
%   を計算する
%
% 例：[x,y,time,numiter]=hits(L,x0,100,1e-8);
%
% 入力：L = 隣接行列（n行n列の疎行列）
%   x0 = 初期ベクトル（行ベクトル）
%   n = 行列Lのサイズ
%   epsilon = 収束の許容度（tolerance）（スカラー、例. 1e-8）
%
% 出力：x = HITS権威ベクトル
%   y = HITSハブベクトル
%   time = 収束までの時間
%   numiter = 収束までの繰り返しの数
%
% 初期ベクトルは通常一様ベクトル（the uniform vector）である。
% x0=1/n*ones(1,n)

% 入力データ
n = 10067;
x0 = 1 / n * ones(1, n);
epsilon = 1e-8;
L = load(".././data/matrix/hits_fate_20161113.txt");

% HITSスコアの計算
k = 0;
residual = 1;
x = x0;
tic;
while (residual >= epsilon)
  prevx = x;
  k = k + 1;
  x = x * L';
  x = x * L;
  x = x / sum(x);
  residual = norm(x - prevx, 1);
end
y = x * L';
y = y / sum(y);
numiter = k;
time = toc;

% HITSスコアをソートして出力
id = 1:1:n;
hits = cat(1,id,y)';
hits_sort = sortrows(hits, -2);
save -text .././data/hits/hits_fate_20161113.txt hits_sort;

