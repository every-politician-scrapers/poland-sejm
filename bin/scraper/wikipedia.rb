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
    member_links.map { |li| fragment(li => Member).to_h }
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
  GROUPS = {
    'Klub Parlamentarny Koalicja Obywatelska – Platforma Obywatelska, Nowoczesna, Inicjatywa Polska, Zieloni' => 'Q108524655',
    'Klub Parlamentarny Koalicja Polska – PSL, UED, Konserwatyści' => 'Q108524672',
    'Koalicyjny Klub Parlamentarny Lewicy (Nowa Lewica, PPS, Razem, Wiosna Roberta Biedronia)' => 'Q108524674',
    'Klub Parlamentarny Prawo i Sprawiedliwość' => 'Q108524676',
    'Koło Parlamentarne Polska 2050' => 'Q108524677',
    'Koło Parlamentarne Porozumienie Jarosława Gowina' => 'Q108524679',
    'Koło Poselskie Konfederacja' => 'Q108524680',
    'Koło Poselskie Kukiz’15 – Demokracja Bezpośrednia' => 'Q108524687',
    'Koło Poselskie Polskie Sprawy' => 'Q108524690',
    'Posłowie niezrzeszeni' => 'Q327591',
  }

  field :item do
    name_link.attr('wikidata')
  end

  field :name do
    name_link.text.tidy
  end

  field :group do
    GROUPS[groupname]
  end

  field :groupname do
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
