require "faker"

p 'Creating users...'
15_000.times { User.create(name: Faker::FunnyName.name_with_initial) }

p 'Creating artists...'
1_000.times do
  artist = Artist.create(
    name: Faker::Artist.name,
    age: rand(12..80)
  )

  p 'Creating albums...'
  rand(5..50).times do
    album = Album.create(title: Faker::Music.album)
    rand(0..20).times do
      user = User.order('RANDOM()').first
      album.ratings.create(user: user, vote: rand(1..5))
    end

    artist.albums << album
    
    p 'Creating songs...'
    rand(5..10).times do
      song = Song.create(
        title: "Faker::Music::#{%w[GratefulDead Phish UmphreysMcgee].sample}".constantize.song,
        duration: rand(120..500)
      )
      artist.songs << song
      rand(0..30).times do
        user = User.order('RANDOM()').first
        song.ratings.create(user: user, vote: rand(1..5))
      end
    end
  end
  artist.save!
end