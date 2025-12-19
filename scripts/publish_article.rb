#!/usr/bin/env ruby
require 'fileutils'

ROOT_DIR   = Dir.pwd
STOCK_DIR  = File.join(ROOT_DIR, 'stock')
PUBLIC_DIR = File.join(ROOT_DIR, 'public')

PUBLISHED_TITLE_PATH = File.join(ROOT_DIR, 'published_title.txt')
PUBLISHED_URL_PATH   = File.join(ROOT_DIR, 'published_url.txt')

YOUR_QIITA_ACCOUNT = 'Taira0222'  # ご自身のQiitaアカウント名に変更してください

# ファイルから updated_at の日付を抽出する
def extract_updated_at(file_path)
  content = File.read(file_path)
  match = content.match(/^updated_at:\s*['"]?(\d{4}-\d{2}-\d{2})T/)
  match ? match[1] : nil
rescue StandardError => e
  warn "Error reading #{file_path}: #{e}"
  nil
end

# public 内のファイルを updated_at 順にリネームする
def normalize_public_articles
  return unless Dir.exist?(PUBLIC_DIR)

  Dir.chdir(PUBLIC_DIR) do
    md_files = Dir.glob('*.md')
    return if md_files.empty?

    puts "Normalizing #{md_files.size} files in public directory..."

    # 全ファイルの updated_at を取得
    file_dates = {}
    md_files.each do |file|
      date = extract_updated_at(file)
      file_dates[file] = date if date
    end

    return if file_dates.empty?

    # 日付順にソート（古い順）
    sorted_files = file_dates.sort_by { |_file, date| date }.map(&:first)

    # 一時ファイル名にリネーム
    temp_names = {}
    sorted_files.each_with_index do |file, index|
      temp_name = "_temp_article_#{index + 1}.md"
      temp_names[file] = temp_name
      FileUtils.mv(file, temp_name)
    end

    # 最終的な article 名にリネーム
    sorted_files.each_with_index do |original_file, index|
      article_num = index + 1
      new_name = "article#{article_num}.md"
      FileUtils.mv(temp_names[original_file], new_name)
    end

    puts "Normalized #{sorted_files.size} files to article*.md format."
  end
end

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

# Qiita CLI で公開し、公開 URL を返す（ファイル名を指定）
def publish_article_by_filename(filename)
  Dir.chdir(ROOT_DIR) do
    # 拡張子なしのファイル名で publish
    base_name = File.basename(filename, '.md')
    cmd = "npx qiita publish #{base_name}"
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

  # 1. stock から public に移動（リネームせず）
  oldest_stock = find_oldest_stock(STOCK_DIR)
  puts "Moving file: #{oldest_stock}"
  moved_path = move_stock_to_public(oldest_stock)

  # 2. タイトルを抽出
  title = extract_title(moved_path)
  puts "Extracted title: #{title}"
  File.write(PUBLISHED_TITLE_PATH, title)

  # 3. 先に publish（これで updated_at が付与される）
  published_url = publish_article_by_filename(oldest_stock)
  puts "Published URL: #{published_url}"
  File.write(PUBLISHED_URL_PATH, published_url)

  # 4. 全ファイルを updated_at 順に article*.md にリネーム
  normalize_public_articles

  # 5. 最新の article 番号を取得してコミット
  article_num = next_article_number - 1
  puts "New article renamed to: article#{article_num}.md"

  commit_and_push(ROOT_DIR, "Add article#{article_num}")
end

main