#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'csv'

DOMAIN_URL = 'https://link.springer.com/'.freeze
pdfs = []
epubs = []

def construct_url(path)
  "#{DOMAIN_URL}#{path}"
end

START_PAGE = 1
END_PAGE = 24 # change if it there are more pages
count = 1
CSV.open("./result.csv", "wb", write_headers: true, headers: ['Title', 'Pdf', 'Epub']) do |csv|
  (START_PAGE..END_PAGE).each do |i|
    url = "#{DOMAIN_URL}search/page/#{i}?facet-content-type=%22Book%22&package=mat-covid19_textbooks"
    doc = Nokogiri::HTML(open(url))
    puts "> PAGE: #{i}"
    doc.css('.title').each do |a|
      row = []
      puts "Total:    #{count}"
      puts "Per page: #{count%10}"
      book_page = Nokogiri::HTML(open("#{DOMAIN_URL}#{a[:href]}"))
      row << book_page.css('.page-title').text.strip.gsub(/\s+/, ' ')
      unless book_page.css('.test-bookpdf-link').empty?
        pdfs << book_page.css('.test-bookpdf-link').first[:href]
        row << construct_url(book_page.css('.test-bookpdf-link').first[:href])
      else
        # prevent epub link if it only have epub
        row << ''
      end
      unless book_page.css('.test-bookepub-link').empty?
        epubs << book_page.css('.test-bookepub-link').first[:href]
        row << construct_url(book_page.css('.test-bookepub-link').first[:href])
      end
      csv << row
      count += 1
    end
  end
end

puts pdfs
puts epubs
