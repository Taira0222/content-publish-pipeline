#!/usr/bin/env ruby
require "x"
require "json"

# 環境変数から x‑ruby 用の認証情報を取得
x_credentials = {
  api_key:             ENV['X_CONSUMER_KEY'],
  api_key_secret:      ENV['X_CONSUMER_SECRET'],
  access_token:        ENV['X_ACCESS_TOKEN_KEY'],
  access_token_secret: ENV['X_ACCESS_TOKEN_SECRET']
}

# クライアントの初期化
x_client = X::Client.new(**x_credentials)

# X の投稿の入れたいハッシュタグを変数に格納
hashtag_qiita = "#Qiita"
hashtag_engineer = "#未経験エンジニア"
hashtag_beginner = "#駆け出しエンジニア"

hashtags = "#{hashtag_qiita}\n#{hashtag_engineer}\n#{hashtag_beginner}"

# 投稿の本文の組み立て
post_text = "#{ENV['POST_TITLE']} #{ENV['POST_URL']}\n#{hashtags}"

# 投稿（JSON形式の文字列を渡す）
payload = { text: post_text }.to_json
post = x_client.post("tweets", payload)

puts "X posted successfully!"
puts "X URL: https://twitter.com/i/web/status/#{post["data"]["id"]}"
