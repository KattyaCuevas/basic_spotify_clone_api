class CreateSongRatingsViews < ActiveRecord::Migration[7.0]
  def change
    create_view :song_ratings_views, materialized: true
  end
end
