#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class MembersPage < Scraped::HTML
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links

  field :members do
    member_links.map { |li| fragment(li => Member) }.select(&:member?).map(&:to_h)
  end

  private

  def member_links
    table.flat_map { |table| table.xpath('.//td//li') }
  end

  def table
    noko.xpath('//h3[contains(.,"Stan aktualny")]/following::table[1]')
  end
end

class Member < Scraped::HTML
  def member?
    true
  end

  field :name do
    name_link.text.tidy
  end

  field :wikidata do
    name_link.attr('wikidata')
  end

  field :party do
    noko.xpath('preceding::th[1]').text.tidy
  end

  private

  def name_link
    noko.css('a').first
  end
end

url = 'https://pl.wikipedia.org/wiki/Pos%C5%82owie_na_Sejm_Rzeczypospolitej_Polskiej_IX_kadencji'
data = MembersPage.new(response: Scraped::Request.new(url: url).response).members

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
