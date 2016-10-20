set :output, 'log/crontab.log' # 出力先のログファイルの指定
set :environment, :production # ジョブの実行環境の指定
job_type :rbenv_rake, "export PATH=\"$HOME/.rbenv/bin:$PATH\"; eval \"$(rbenv init -)\";cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"
# job_type :rbenv_rake, %q!PATH="$HOME/.rbenv/bin:$PATH"; eval "$(rbenv init -)"; cd :path && :bundle_command rake :task --silent :output!
# job_type :rbenv_rake, "export PATH=\"$HOME/.rbenv/bin:$PATH\"; eval \"$(rbenv init -)\"; cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"
every 1.minutes do
  rbenv_rake "bot:search"
end
