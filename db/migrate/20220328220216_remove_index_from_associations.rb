class RemoveIndexFromAssociations < ActiveRecord::Migration[7.0]
  def change
    remove_index :associations, name: :index_association_on_album_id
    remove_index :associations, name: :index_association_on_artist_id
    remove_index :associations, name: :index_association_on_song_id
  end
end
