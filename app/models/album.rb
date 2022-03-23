class Album < ApplicationRecord
  has_and_belongs_to_many :artist, join_table: 'association'
  has_and_belongs_to_many :song, join_table: 'association'

  has_many :ratings, as: :votable
end
