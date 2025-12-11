#!/usr/bin/env ruby
require 'fileutils'

ROOT_DIR   = Dir.pwd
STOCK_DIR  = File.join(ROOT_DIR, 'stock')
PUBLIC_DIR = File.join(ROOT_DIR, 'public')

PUBLISHED_TITLE_PATH = File.join(ROOT_DIR, 'published_title.txt')
PUBLISHED_URL_PATH   = File.join(ROOT_DIR, 'published_url.txt')

YOUR_QIITA_ACCOUNT = 'Taira0222'  # ご自身のQiitaアカウント名に変更してください

# 次に公開する stock*.md を最小番号で選ぶ
def find_oldest_stock(stock_dir)
  stock_files = Dir.children(stock_dir).grep(/^stock(\d+)\.md$/)
  raise 'stock ディレクトリ内に対象ファイルが見つかりません。' if stock_files.empty?

  stock_files.min_by { |file| file[/\d+/, 0].to_i }
end

# 選んだ stock を public に移動する
def move_stock_to_public(filename)
  source_path = File.join(STOCK_DIR, filename)
  dest_path   = File.join(PUBLIC_DIR, filename)
  FileUtils.mv(source_path, dest_path)
  dest_path
end

# 既存の article*.md から次の記事番号を決める
def next_article_number
  article_files = Dir.children(PUBLIC_DIR).grep(/^article(\d+)\.md$/)
  return 1 if article_files.empty?

  article_files.map { |file| file[/\d+/, 0].to_i }.max + 1
end

# 移動した stock を article 名にリネームする
def rename_to_article(path, article_num)
  new_name = "article#{article_num}.md"
  new_path = File.join(PUBLIC_DIR, new_name)
  FileUtils.mv(path, new_path)
  new_path
end

# 記事中の title: 行を取り出して控えておく
def extract_title(article_path)
  content = File.read(article_path)
  title_line = content.lines.find { |line| line.strip.start_with?('title:') }
  title_line ? title_line.sub(/^title:\s*/, '').strip : ''
rescue StandardError => e
  warn "Error extracting title: #{e}"
  ''
end

# Qiita CLI で公開し、公開 URL を返す
def publish_article(article_num)
  Dir.chdir(ROOT_DIR) do
    cmd = "npx qiita publish article#{article_num}"
    puts "Running command: #{cmd}"
    cli_output = `#{cmd}`.strip
    puts "CLI output: #{cli_output}"

    article_id = cli_output.split('->').last&.strip
    raise 'Qiita CLI 出力から記事IDを取得できませんでした。' unless article_id && !article_id.empty?

    url = "https://qiita.com/#{YOUR_QIITA_ACCOUNT}/items/#{article_id}"
    url.split("\n").first.strip
  end
end

# 指定ディレクトリで git add/commit/push するヘルパー
def commit_and_push(dir, message)
  Dir.chdir(dir) do
    puts "Running command: git add -A"
    system('git add -A')

    puts "Running command: git commit -m \"#{message}\""
    system(%(git commit -m "#{message}"))

    puts 'Running command: git push'
    system('git push')
  end
end

# 公開フロー全体を実行する
def main
  raise 'stock ディレクトリが見つかりません。' unless Dir.exist?(STOCK_DIR)
  FileUtils.mkdir_p(PUBLIC_DIR)

  oldest_stock = find_oldest_stock(STOCK_DIR)
  puts "Moving file: #{oldest_stock}"
  moved_path = move_stock_to_public(oldest_stock)

  article_num = next_article_number
  puts "Renaming moved file to: article#{article_num}.md"
  article_path = rename_to_article(moved_path, article_num)

  title = extract_title(article_path)
  puts "Extracted title: #{title}"
  File.write(PUBLISHED_TITLE_PATH, title)

  published_url = publish_article(article_num)
  puts "Published URL: #{published_url}"
  File.write(PUBLISHED_URL_PATH, published_url)

  commit_and_push(ROOT_DIR, "Add article#{article_num}")
end

main