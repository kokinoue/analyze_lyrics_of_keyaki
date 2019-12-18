class KeyakiSongs
  require 'csv'
  require 'English'
  require 'natto'
  require 'nokogiri'
  require 'open-uri'
  require 'pry'

  POPULAR_RANKING_URL = 'https://www.uta-net.com/artist/19868/4/'
  TOP10 = 9

  def run
    doc = Nokogiri::HTML.parse(open(POPULAR_RANKING_URL), nil, 'utf-8')
    words = []
    doc.css('.td1').each_with_index do |f, i|
      link = f.children[0][:href]
      url = "https://www.uta-net.com#{link}"
      song = Nokogiri::HTML.parse(open(url), nil, 'utf-8')
      title = song.css('.title > h2').text
      run_natto(song, title, words)
      break if i == TOP10
    end
    puts words
    hash = words.group_by(&:itself).map{ |key, value| [key, value.count] }.to_h
    create_csv(hash)
  end

  def run_natto(song, title, words)
    natto = Natto::MeCab.new('-F%m:\s%f[0]')
    natto.enum_parse(song.css('#kashi_area').text).each do |n|
      array = n.feature.split(': ')
      if array[1] == '助詞' || array[1] == '助動詞' || array[1] == '記号'
        next
      else
        words << array[0]
      end
    end
  end

  def create_csv(hash)
    CSV.open('file.csv', 'w') do |csv|
      csv << %w[ワード カウント]
      hash.each do |key, value|
        csv << [key, value]
      end
    end
  end
end

keyaki_songs = KeyakiSongs.new
keyaki_songs.run
