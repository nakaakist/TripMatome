# -*- coding: utf-8 -*-
require 'json'
require 'httpclient'
require 'clockwork'
require 'nokogiri'
require 'date'

require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)

def fetch_article(site_name, site_url, xpath, title_url_getter)
  prev_fetched_urls = []
  Article.find_by_sql(['select url from articles where website = ?', site_name]).each do |article|
    prev_fetched_urls.push(article.url)
  end
  p prev_fetched_urls
  client = HTTPClient.new
  html = client.get_content(site_url)
  parsed_html = Nokogiri.parse(html)
  parsed_html.xpath(xpath).each do |elem|
    title, url, date, img_url = title_url_getter.call(elem)
    next if prev_fetched_urls.include?(url)
    unless prev_fetched_urls.empty?
      date = DateTime.now
    end
    article = Article.new({'title'=> title, 'website'=> site_name, 'url'=> url, 'datetime'=> date, 'img_url' => img_url})
    article.save
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
                  img_url = elem.xpath('.//img')[0].attribute('src').value
                  p img_url
                  return title, url, date, img_url
                end
               )
  fetch_article('Tsunagu Japan',
                'https://www.tsunagujapan.com',
                '//div[@class="vwpc-section-latest"]//div[@class="post-box-wrapper col-sm-4"]',
                lambda do |elem|
                  title = elem.xpath('.//h3[@class="title"]/a')[0].text
                  p title
                  url = elem.xpath('.//h3[@class="title"]/a')[0].attr('href')
                  p url
                  date = elem.xpath('.//a[@class="post-date"]')[0].text
                  p date
                  img_url = elem.xpath('.//img')[0].attribute('src').value
                  p img_url
                  return title, url, date, img_url
                end
               )
  fetch_article('Japan Travel',
                'http://en.japantravel.com',
                '//div[@id="latest_articles"]//div[@class="subject rowblock clearfix"]',
                lambda do |elem|
                  title = elem.xpath('.//div[@class="text"]//a')[0].text
                  p title
                  url = 'http://en.japantravel.com' + elem.xpath('.//div[@class="text"]//a')[0].attr('href')
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
                  img_url = elem.xpath('.//img')[0].attribute('src').value
                  p img_url
                  return title, url, date, img_url
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
                  img_url = 'http://illustration.artlesskitchen.com/data/flower/sakura02_b.jpg'
                  p img_url
                  return title, url, date, img_url
                end
               )
end
