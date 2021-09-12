#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'

# Standardise data
class Comparison < EveryPoliticianScraper::Comparison
  REMAP = {
    'bezpartyjny' => 'niez.',
  }.freeze

  def wikidata_csv_options
    { converters: [->(val) { REMAP.fetch(val, val) }] }
  end
end

diff = Comparison.new('wikidata/results/current-members.csv', 'data/official.csv').diff
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
