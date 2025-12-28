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

# 投稿の送信とエラーハンドリング
begin
  post = x_client.post("tweets", payload)
  puts "X posted successfully!"
  puts "X URL: https://x.com/i/web/status/#{post["data"]["id"]}"
rescue X::Error => e
  puts "X API Error: #{e.class}"
  puts "Message: #{e.message}"
  puts ""
  puts "詳細情報:"
  puts "- HTTP Status: #{e.respond_to?(:code) ? e.code : 'N/A'}"
  puts "- Response Body: #{e.respond_to?(:body) ? e.body : 'N/A'}"
  exit 1
rescue StandardError => e
  puts "Unexpected Error: #{e.class}"
  puts "Message: #{e.message}"
  puts "Backtrace: #{e.backtrace.first(5).join("\n")}"
  exit 1
end
