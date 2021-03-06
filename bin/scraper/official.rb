#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'open-uri/cached'
require 'pry'

class Legislature
  # details for an individual member
  class Member < Scraped::HTML
    field :id do
      noko.css('a/@href').text[/id=(\d+)/, 1]
    end

    field :name do
      return 'Szymon Szynkowski vel Sęk' if display_name == 'Szynkowski vel Sęk Szymon'

      display_name.split(' ', 2).reverse.join(' ')
    end

    field :klub_short do
      noko.css('.deputy-box-details strong').text.tidy
    end

    private

    def display_name
      noko.css('.deputyName').text.tidy
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      member_container.map { |member| fragment(member => Member) }.map(&:to_h).uniq
    end

    private

    def member_container
      noko.css('ul.deputies li')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file, klass: Legislature::Members).csv
