class Artist < ApplicationRecord
  has_and_belongs_to_many :songs, join_table: 'association'
  has_and_belongs_to_many :albums, join_table: 'association'
end
