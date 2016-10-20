# 出力先のログファイルの指定
set :output, 'log/crontab.log'
# ジョブの実行環境の指定
set :environment, :production

every 15.minutes do
  rake "bot:search"
end
