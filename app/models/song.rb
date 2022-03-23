class Song < ApplicationRecord
  has_and_belongs_to_many :album, join_table: 'association'
  has_and_belongs_to_many :artists, join_table: 'association'

  has_many :ratings, as: :votable
end
