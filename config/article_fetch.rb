# -*- coding: utf-8 -*-
require 'json'
require 'httpclient'
require 'clockwork'
require 'nokogiri'
require 'date'

require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)

def fetch_article(site_name, site_url, xpath, title_url_getter)

  begin
    prev_fetched_urls = open("article_urls/#{site_name}.json") do |io|
      JSON.load(io)
    end
  rescue => e
    puts e.message
    puts e.class
    prev_fetched_urls = []
  end

  client = HTTPClient.new
  html = client.get_content(site_url)
  parsed_html = Nokogiri.parse(html)
  fetched_urls = []
  parsed_html.xpath(xpath).each do |elem|
    title, url, date = title_url_getter.call(elem)
    fetched_urls.push(url)
    next if prev_fetched_urls.include?(url)
    unless prev_fetched_urls.empty?
      date = DateTime.now
    end
    article = Article.new({'title'=> title, 'website'=> site_name, 'url'=> url, 'datetime'=> date})
    article.save
  end

  open("article_urls/#{site_name}.json", "w") do |io|
    JSON.dump(fetched_urls, io)
  end
end

Clockwork::every(1.hours, 'fetch_article', :at => '**:00') do
  fetch_article('Matcha',
                'http://mcha-jp.com',
                '//div[@class="pickup_box"]',
                lambda do |elem|
                  title = elem.xpath('.//div[@class="pickup_text"]')[0].child.text.gsub(/(\t|\n)/, '')
                  p title
                  url = elem.xpath('a')[0].attr('href')
                  p url
                  date = elem.xpath('.//div[@class="pickup_written"]')[0].text.gsub(/(\t|\n)/, '')[-10, 10]
                  p date
                  return title, url, date
                end
               )
  fetch_article('Tsunagu Japan',
                'https://www.tsunagujapan.com',
                '//div[@class="vwpc-section-latest"]//div[@class="post-box-inner"]',
                lambda do |elem|
                  title = elem.xpath('.//h3[@class="title"]/a')[0].text
                  p title
                  url = elem.xpath('.//h3[@class="title"]/a')[0].attr('href')
                  p url
                  date = elem.xpath('.//a[@class="post-date"]')[0].text
                  p date
                  return title, url, date
                end
               )
  fetch_article('Japan Travel',
                'http://en.japantravel.com',
                '//div[@id="latest_articles"]//div[@class="text"]',
                lambda do |elem|
                  title = elem.xpath('.//a')[0].text
                  p title
                  url = 'http://en.japantravel.com' + elem.xpath('.//a')[0].attr('href')
                  p url
                  date = elem.xpath('.//span[@class="date visible-lg visible-xs"]').text.gsub(/(\n|\t| |)/, '')
                  if date =~ /hoursago/
                    days = 0
                  elsif date = 'yesterday'
                    days = 1
                  elsif date =~ /daysago/
                    days = date[0...-7].to_i
                  end
                  date = Date.today - days
                  p date
                  return title, url, date
                end
               )
  fetch_article('Japan Endless Discovery',
                'http://us.jnto.go.jp/latest/index.php',
                '//div[@class="contents"]//tr[@height="60"]',
                lambda do |elem|
                  title = elem.xpath('.//a')[0].text
                  p title
                  url = elem.xpath('.//a')[0].attr('href')
                  if url[0..1] == '..'
                    url = 'http://us.jnto.go.jp/' + url[3..-1]
                  end
                  p url
                  date = elem.xpath('./td[@class="date"]')[0].text[0...-1]
                  p date
                  return title, url, date
                end
               )
end
