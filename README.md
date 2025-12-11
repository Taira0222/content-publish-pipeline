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

### 3. Qiita CLI をインストール

```bash
npm install
```

### 4. Qiita アカウント設定

`scripts/publish_article.rb` 内の以下を、自分の Qiita アカウント名に変更：

```ruby
YOUR_QIITA_ACCOUNT = 'Taira0222'
```

### 5. X（Twitter）投稿設定

`scripts/post_x.rb` の `hashtags` を好みのタグに設定してください。

### 6. GitHub Actions の投稿タイミング設定

`.github/workflows/publish_post.yml` 内の cron を好きな時間に設定してください。
※GitHub Actions は UTC で実行され、数十分〜数時間前後ズレることがあります。

### 7. Qiita Token を Secrets に登録

GitHub → Settings → Secrets and variables → Actions →
`QIITA_TOKEN` として登録。

### 8. X への投稿に必要な Token の登録

このリポジトリでは x-ruby（[https://sferik.github.io/x-ruby/）を使用します。](https://sferik.github.io/x-ruby/）を使用します。)

以下を X Developer から取得し、GitHub Secrets に登録してください：

| 用途                | Secrets 名例                  |
| ------------------- | ----------------------------- |
| Consumer API Key    | `TWITTER_CONSUMER_KEY`        |
| Consumer API Secret | `TWITTER_CONSUMER_SECRET`     |
| Access Token        | `TWITTER_ACCESS_TOKEN_KEY`    |
| Access Token Secret | `TWITTER_ACCESS_TOKEN_SECRET` |

※ Secrets 名を変更する場合は、`.github/workflows/publish_post.yml`や`scripts/post_x.rb`も同様に変更してください

X Developer 登録方法は以下が参考になります：
[https://qiita.com/newt0/items/66cb76b1c8016e9d0339](https://qiita.com/newt0/items/66cb76b1c8016e9d0339)

---

## ✏️ 使い方：記事の追加

1. `template/` にあるサンプル記事をコピー
2. `stock/stockNNN.md` の形式でファイルを作成
3. あとは GitHub Actions が毎日 or 設定した時刻に、自動で：

   - 最小番号の `stock*.md` を pick
   - `article*.md` として公開
   - Qiita に投稿
   - X にも投稿
   - GitHub に commit & push

---

## 🎉 これで準備完了です！

Qiita と X への毎日投稿を完全自動化できます。
