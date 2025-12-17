# content-publish-pipeline

Qiita と X（Twitter）に記事を自動投稿するための、
**コンテンツ管理 + GitHub Actions（cron）自動投稿システム**です。

このリポジトリだけで記事管理が完結する構成です。

- 未公開：`stock/`
- 公開済み：`public/`
- 自動投稿スクリプト：`scripts/`

`scripts/` の Ruby スクリプトが、Qiita での公開処理と X への投稿を自動化します。

---

## 🚀 セットアップ

### 1. リポジトリを Fork

GitHub 上でこのリポジトリを Fork してください。

### 2. ローカルへクローン

```bash
git clone https://github.com/<YourAccount>/content-publish-pipeline.git
```

### 3. Qiita アカウント設定

`scripts/publish_article.rb` 内の以下を、自分の Qiita アカウント名に変更：

```ruby
YOUR_QIITA_ACCOUNT = 'YOUR_QIITA_ACCOUNT_NAME'
```

### 4. X（Twitter）投稿設定

`scripts/post_x.rb` の `hashtags` を好みのタグに設定してください。

### 5. GitHub Actions の投稿タイミング設定

`.github/workflows/publish_post.yml` 内の cron を好きな時間に設定してください。
※GitHub Actions は UTC で実行され、数十分〜数時間前後ズレることがあります。

もし自動投稿機能は使わず、手動で行いたい場合は以下のように書く必要があります
```yml
on:
  workflow_dispatch: # この記述が必要
#   schedule:
#     - cron: '0 2 * * *' # UTCで毎日2時に実行(日本時間11時)

```

### 6. Qiita Token を Secrets に登録

Qiita のTokenの取得方法は

1. Qiitaにログインしマイページに行く
2. 右上のアイコンをクリックし「設定」を開く
3. 「アプリケーション」の「個人用アクセストークン」で「新しくトークンを作成する」をクリック
4. 以下の画像通り（名前は適宜変えてもらってOKです）に設定し「発行する」を選択
5. トークンが発行されるので忘れずに保管

![スクリーンショット 2025-12-17 午前11.27.39.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3883070/5d294365-12f1-40c2-a6f6-41e6c4d97a08.png)

これをGitHubに登録します。
1. Forkしたこのレポジトリに移動
2. SettingのSecrets and variables → Actionsと進む
3. Repository secrets の New repository secretをクリック
4. `QIITA_TOKEN` としてさっき取得したトークンをここに貼る

### 7. X への投稿に必要な Token の登録

このリポジトリでは [x-ruby](https://sferik.github.io/x-ruby/)を使用します。

以下を X Developer から取得し、GitHub Secrets に登録してください：

| 用途                | Secrets 名例                  |
| ------------------- | ----------------------------- |
| Consumer API Key    | `X_CONSUMER_KEY`        |
| Consumer API Secret | `X_CONSUMER_SECRET`     |
| Access Token        | `X_ACCESS_TOKEN_KEY`    |
| Access Token Secret | `X_ACCESS_TOKEN_SECRET` |


X Developer 登録方法は以下が参考になります：
[https://qiita.com/newt0/items/66cb76b1c8016e9d0339](https://qiita.com/newt0/items/66cb76b1c8016e9d0339)

登録が完了したら、以下の画像の「Projects & Apps」下の赤い丸を選択し、
「Consumer Keys」と「Authenticate Tokens」の「Access Token and Secret」の情報を
上記の`QIITA_TOKEN` 同様にGitHubに登録してください

![スクリーンショット 2025-12-17 午前11.59.14.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3883070/2add4b8a-9298-4f90-9b10-dee64b156a21.png)

---

## ✏️ 使い方：記事の追加

1. `template/` にあるサンプル記事をコピー
2. `stock/stockNNN.md` の形式でファイルを作成(`NNN`には数字を入れてくださいex: `stock256.md`)
3. あとは GitHub Actions が毎日 or 設定した時刻に、自動で：

   - 最小番号の `stock*.md` を pick
   - `article*.md` として公開
   - Qiita に投稿
   - X にも投稿
   - GitHub に commit & push
   - 次使う場合は`git pull` してから使用してください。(`public`に記事が投稿されているため)

---

## 🎉 これで準備完了です！

Qiita と X への毎日投稿を完全自動化できます。
