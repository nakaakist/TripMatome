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
    prev_fetched_urls = []
    open("../tmp/#{site_name}.json") do |io|
      prev_fetched_urls.push(JSON.load(io))
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
    title, url = title_url_getter.call(elem)
    fetched_urls.push(url)
    next if prev_fetched_urls.include?(url)
    article = Article.new({'title'=> title, 'website'=> site_name, 'url'=> url, 'datetime'=> DateTime.now})
    article.save
  end

  open("../tmp/#{site_name}.json", "w") do |io|
    JSON.dump(fetched_urls, io)
  end
end

Clockwork::every(6.hours, 'fetch_article') do
  fetch_article('Matcha',
                'http://mcha-jp.com',
                '//div[@class="pickup_box"]',
                lambda do |elem|
                  title = elem.xpath('.//div[@class="pickup_text"]')[0].child.text.gsub(/(\t|\n)/, '')
                  p title
                  url = elem.xpath('a')[0].attr('href')
                  p url
                  return title, url
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
                  return title, url
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
                  return title, url
                end
               )
  fetch_article('Japan Endless Discovery',
                'http://us.jnto.go.jp/latest/index.php',
                '//div[@class="contents"]//a[@target="_blank"]',
                lambda do |elem|
                  title = elem.text
                  p title
                  url = elem.attr('href')
                  p url
                  return title, url
                end
               )
end
