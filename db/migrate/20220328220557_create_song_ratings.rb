class CreateSongRatings < ActiveRecord::Migration[7.0]
  def change
    create_view :song_ratings
  end
end
