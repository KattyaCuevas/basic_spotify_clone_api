class CreateJoinTableSongArtistAlbum < ActiveRecord::Migration[7.0]
  def change
    create_table :association do |t|
      t.references :song
      t.references :artist
      t.references :album
    end
  end
end
