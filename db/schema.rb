# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_03_29_151341) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "association", force: :cascade do |t|
    t.bigint "song_id"
    t.bigint "artist_id"
    t.bigint "album_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "vote", default: 0
    t.string "votable_type"
    t.bigint "votable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ratings_on_user_id"
    t.index ["votable_type", "votable_id"], name: "index_ratings_on_votable"
  end

  create_table "songs", force: :cascade do |t|
    t.string "title"
    t.integer "duration"
    t.integer "progress"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "ratings", "users"

  create_view "song_ratings", sql_definition: <<-SQL
      SELECT songs_ratings.id,
      songs_ratings.title,
      songs_ratings.rating,
      albums.id AS album_id,
      albums.title AS album_title,
      artists.id AS artist_id,
      artists.name AS artists_name
     FROM (((( SELECT songs.id,
              songs.title,
              avg(ratings.vote) AS rating
             FROM (ratings
               JOIN songs ON ((ratings.votable_id = songs.id)))
            WHERE ((ratings.votable_type)::text = 'Song'::text)
            GROUP BY ratings.votable_id, songs.id) songs_ratings
       JOIN association ON ((association.song_id = songs_ratings.id)))
       JOIN albums ON ((association.album_id = albums.id)))
       JOIN artists ON ((association.artist_id = artists.id)));
  SQL
  create_view "song_ratings_views", materialized: true, sql_definition: <<-SQL
      SELECT songs_ratings.id,
      songs_ratings.title,
      songs_ratings.rating,
      albums.id AS album_id,
      albums.title AS album_title,
      artists.id AS artist_id,
      artists.name AS artists_name
     FROM (((( SELECT songs.id,
              songs.title,
              avg(ratings.vote) AS rating
             FROM (ratings
               JOIN songs ON ((ratings.votable_id = songs.id)))
            WHERE ((ratings.votable_type)::text = 'Song'::text)
            GROUP BY ratings.votable_id, songs.id) songs_ratings
       JOIN association ON ((association.song_id = songs_ratings.id)))
       JOIN albums ON ((association.album_id = albums.id)))
       JOIN artists ON ((association.artist_id = artists.id)));
  SQL
end
