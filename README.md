# rails8

perfect rails8

## 初期構築

ディレクトリにあるファイルは以下の通り

```bash
Gemfile
Gemfile.lock
README.md
dip.yml
docker-compose.yml
```

事前に`mysql@8.0`をインストールした状態で、以下の通りシェルにセットしておく

```bash
brew install mysql@8.0
bundle config --local build.mysql2 "--with-mysql-dir=$(brew --prefix mysql@8.0)"
```

その上でbundleを実行して、rails newする。

```bash
dip bundle
dip rails new .
```

## 色々やろうぜ

`cleanup.sh`を実行する事で`rails new`して出来たファイル群を作成し、新たに`rails new`を実行する事ができる。

## routingを確認する

知らなかったけど、以下でさくっとルーティング情報がわかるみたい。

<http://rails7.lvh.me:53000/rails/info/routes>

## h2oでEarly Hintsを試す(※)

※注 このセクションはうまく動作しなかった為、参考程度にしておく。
h2oをインストール(`brew install h2o`)して、`/Users/teruo.kakikubo/brew/etc/h2o/h2o.conf`を以下の通りに編集する

```bash
teruo.kakikubo@C02DN0TXML87 ~/brew/etc/h2o % cat h2o.conf
#listen: 8080
#hosts:
#  "127.0.0.1.xip.io:8080":
#    paths:
#      /:
#        file.dir: /Users/teruo.kakikubo/brew/var/h2o/
hosts:
  localhost:
    listen:
      port: 9090
      ssl:
        certificate-file: /Users/teruo.kakikubo/brew/etc/h2o/localhost.crt
        key-file: /Users/teruo.kakikubo/brew/etc/h2o/localhost.key
    paths:
      /:
        proxy.reverse.url: http://127.0.0.1:53000/
        proxy.preserve-host: ON
access-log: /Users/teruo.kakikubo/brew/var/h2o/access-log
error-log: /Users/teruo.kakikubo/brew/var/h2o/error-log
```

証明書情報を以下のように作成、配置する

```bash
teruo.kakikubo@C02DN0TXML87 ~/brew/etc/h2o % openssl req -nodes -x509 -new \
-days 36500 -subj "/CN=localhost" \
-keyout /Users/teruo.kakikubo/brew/etc/h2o/localhost.key \
-out /Users/teruo.kakikubo/brew/etc/h2o/localhost.crt
Generating a RSA private key
..............................................................................................+++++
............................................................................+++++
writing new private key to '/Users/teruo.kakikubo/brew/etc/h2o/localhost.key'
-----
```

h2oを起動する

```bash
% h2o -c /Users/teruo.kakikubo/brew/etc/h2o/h2o.conf
```

## Sidekiqを利用する

<http://rails7.lvh.me:53000/sidekiq>

FIXME ちょっと謎な動き。

```bash
irb(main):007:0> AsyncLogJob.perform_later(message: '44')
irb(main):002:0> AsyncLog.last
  AsyncLog Load (0.7ms)  SELECT `async_logs`.* FROM `async_logs` ORDER BY `async_logs`.`id` DESC LIMIT 1
=> #<AsyncLog id: 14, message: "bbb", created_at: "2021-03-12 21:04:08.776910000 +0000", updated_at: "2021-03-12 21:04:08.776910000 +0000">
```

`sidekiq`を起動してない状態だと上記のようにperform_laterが処理されず、
キューに溜まったままの状態になるのだが、これを別ターミナルで

```bash
dip bundle exec sidekiq
```

とすると

```bash
irb(main):008:0> AsyncLog.last
  AsyncLog Load (1.0ms)  SELECT `async_logs`.* FROM `async_logs` ORDER BY `async_logs`.`id` DESC LIMIT 1
=> #<AsyncLog id: 15, message: "44", created_at: "2021-03-15 21:07:55.098130000 +0000", updated_at: "2021-03-15 21:07:55.098130000 +0000">
```

きちんと処理され、

```bash
dip up worker
```

とすると、perform_laterで`sidekiq`を起動しても何も処理されない。
どういう事だろうか。。。

## bullet

```bash
dip rails g bullet:install
```

## webpack

きちんとやっておこう

```bash
dip rails assets:precompile
```

## skylight

```bash
teruo.kakikubo@C02DN0TXML87 ~/Documents/rails7 % dip bundle exec skylight setup wfY88nn7tx0p
Creating rails7_web_run ... done
W, [2021-03-30T07:47:43.025198 #21]  WARN -- Skylight: [SKYLIGHT] [5.0.1] Running Skylight in development mode. No data will be reported until you deploy your app.
(To disable this message for all local apps, run `skylight disable_dev_warning`.)
Running via Spring preloader in process 41
Congratulations. Your application is on Skylight! https://www.skylight.io

The application was registered for you and we generated a config file
containing your API token at:

  config/skylight.yml

The next step is for you to deploy your application to production. The
easiest way is to just commit the config file to your source control
repository and deploy from there. You can learn more about the process at:

  https://docs.skylight.io/getting-set-up/#deployment

If you want to specify the authentication token as an environment variable,
you should set the `SKYLIGHT_AUTHENTICATION` variable to:

  E2movt18Qd0UnzxeJKZJ51TfV5pBTE7FcBiPZRxUXWk
```

## Docker

Dockerfileを単体で用意してあるのでそちらを利用する。.dockerignoreも参照

```bash
docker build -t myrailsapp .
docker run -p 3000:3000 myrailsapp
```

buildkitで高速化した例

```bash
DOCKER_BUILDKIT=1 docker build -t myrailsapp -f Dockerfile-buildkit .
docker run -p 3000:3000 myrailsapp
```

## SimpleCov

テスト結果は毎度 coverage/index.html として出力されているのでそちらを
参照しつつカバレッジをあげていく

```bash
dip rspec
open coverage/index.html
```

## FIXME

`Event.reindex` を実行していないと以下のログが出て前に進めない。

```bash
Searchkick::MissingIndexError (Index missing - run Event.reindex):
```

どうにか、初期化時になんとかする事はできないのか。

```bash
dip rails searchkick:reindex CLASS=Event
```

結局上記をprovisionに含めるしかなさそうかな。。

### 他のユーザが作成したイベントに参加できない

- [x] テストケースを書く
- [ ] 修正する
- [ ] publishしてくれよ
