class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :votable

  belongs_to :votable, polymorphic: true
end
