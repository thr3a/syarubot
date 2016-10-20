set :output, 'log/crontab.log' # 出力先のログファイルの指定
set :environment, :production # ジョブの実行環境の指定
job_type :rbenv_rake, %q!eval "$(rbenv init -)"; cd :path && :environment_variable=:environment bundle exec rake :task --silent :output!

every 1.minutes do
  rbenv_rake "bot:search"
end
