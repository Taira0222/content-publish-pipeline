#!/usr/bin/env ruby
require "x"
require "json"

# 環境変数から x‑ruby 用の認証情報を取得
x_credentials = {
  api_key:             ENV['TWITTER_CONSUMER_KEY'],
  api_key_secret:      ENV['TWITTER_CONSUMER_SECRET'],
  access_token:        ENV['TWITTER_ACCESS_TOKEN_KEY'],
  access_token_secret: ENV['TWITTER_ACCESS_TOKEN_SECRET']
}

# クライアントの初期化
x_client = X::Client.new(**x_credentials)

# X の投稿の入れたいハッシュタグを変数に格納
hashtag_qiita = "#Qiita"
hashtag_engineer = "#未経験エンジニア"
hashtag_beginner = "#駆け出しエンジニア"

hashtags = "#{hashtag_qiita}\n#{hashtag_engineer}\n#{hashtag_beginner}"

# ツイート本文の組み立て
tweet_text = "#{ENV['TWEET_TITLE']} #{ENV['TWEET_URL']}\n#{hashtags}"

# ツイート投稿（JSON形式の文字列を渡す）
payload = { text: tweet_text }.to_json
post = x_client.post("tweets", payload)

puts "Tweet posted successfully!"
puts "Tweet URL: https://twitter.com/i/web/status/#{post["data"]["id"]}"
