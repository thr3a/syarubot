# オレオレRails

Nginxの利用を想定したRailsテンプレート

- ruby 2.3.0
- Rails 4.2.6
- MySQL
- Capistrano Version: 3.5.0
- Puma(仮)

# インストール

```
git clone https://github.com/thr3a/myrails.git
cd myrails
bundle install
```

# 初期設定

**config/application.rb** にてサービス名の設定

```ruby
module Myrails
  class Application < Rails::Application
    config.title = "My rails"
  end
end
```

# デプロイの設定

予めデプロイ先にはrbev＆ruby2.3.0&nginxを入れておく

**.gitignore** に以下を追加

```
/config/secrets.yml
/config/database.yml
```

インデックスから削除

```
git rm --cached -f config/secrets.yml
git rm --cached -f config/database.yml
```

**config/database.yml** と **config/secrets.yml** の設定を行う

**config/deploy/production.rb** と **config/deploy.rb** でそれぞれ設定

# デプロイ

```
bundle exec cap production deploy:mkdir
bundle exec cap production deploy:upload
bundle exec cap production deploy
```

pumaの設定変更したら `bundle exec cap production puma:config` すること

# その他

### モデルのバリデーションメッセージ出したい

```ruby
flash[:danger] = @post.errors.full_messages
```
