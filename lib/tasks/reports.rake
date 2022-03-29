require 'benchmark'
require 'benchmark-memory'
require 'benchmark/ips'

namespace :reports do
  desc 'First Report: Highest rating in albums'

  def rating_ar_ruby
    Album.includes(:ratings).map { |album| album.ratings.length }.max
  end

  def rating_only_ar
    Album.from(Album.select(
      'albums.*', 'COUNT(ratings.id) AS rating_count'
    ).joins(:ratings).group('albums.id')).maximum('rating_count')
  end

  task first: :environment do
    puts "\n\n\n"
    puts '--- Elapsed Time ----------------------'
    Benchmark.bmbm do |x|
      x.report('Active Record + Ruby code') { rating_ar_ruby }
      x.report('Only Active Record') { rating_only_ar }
    end

    puts "\n\n\n"

    puts '--- Memory ----------------------------'
    Benchmark.memory do |x|
      x.report('Active Record + Ruby code') { rating_ar_ruby }
      x.report('Only Active Record') { rating_only_ar }
      x.compare!
    end

    puts "\n\n\n"

    puts '--- Iterations per Second -------------'
    Benchmark.ips do |x|
      x.report('Active Record + Ruby code') { rating_ar_ruby }
      x.report('Only Active Record') { rating_only_ar }
      x.compare!
    end
  end

  desc 'Second Report: Top 10 rated songs'

  def first_solution(n)
    ratings = Rating.where(votable_type: 'Song').group(:votable_id).average(:vote)
                    .sort_by { |r| -r[1] }.take(n).to_h
    songs = Song.includes(:artists).find(ratings.keys)
    ratings.map do |song_id, rating|
      song = songs.find { |s| s.id == song_id }
      {
        id: song.id,
        song: song.title,
        artist: song.artists.map(&:name).join(', '),
        rating_avg: rating.to_f
      }
    end
  end

  def second_solution(n)
    Song.includes(:artists).joins(:ratings)
        .select('songs.*, AVG(ratings.vote) as rating_avg')
        .group('songs.id').order('rating_avg DESC').limit(n)
        .map do |song|
          {
            song: song.title,
            artist: song.artists.map(&:name).join(', '),
            rating_avg: song.rating_avg
          }
        end
  end

  def third_solution(n)
    ratings = Rating.select('ratings.votable_id, AVG(ratings.vote) as rating_avg')
                    .where(votable_type: 'Song')
                    .group(:votable_id).order('rating_avg DESC').limit(n)
    Song.includes(:artists).find(ratings.map(&:votable_id)).map do |song|
      {
        song: song.title,
        artist: song.artists.map(&:name).join(', '),
        rating_avg: ratings.find { |rating| rating.votable_id == song.id }.rating_avg
      }
    end
  end

  def measure(n)
    puts "\n\n\n"
    puts '--- Elapsed Time ----------------------'
    Benchmark.bmbm do |x|
      x.report('Active Record + Ruby code') { first_solution(n) }
      x.report('Only Active Record') { second_solution(n) }
      x.report('Active Record + Ruby code v2') { third_solution(n) }
    end

    puts "\n\n\n"
    puts '--- Memory ----------------------------'
    Benchmark.memory do |x|
      x.report('Active Record + Ruby code') { first_solution(n) }
      x.report('Only Active Record') { second_solution(n) }
      x.report('Active Record + Ruby code v2') { third_solution(n) }
      x.compare!
    end

    puts "\n\n\n"
    puts '--- Iterations per Second -------------'
    Benchmark.ips do |x|
      x.report('Active Record + Ruby code') { first_solution(n) }
      x.report('Only Active Record') { second_solution(n) }
      x.report('Active Record + Ruby code v2') { third_solution(n) }
      x.compare!
    end
  end

  task second: :environment do
    measure(10)
  end


  desc 'Third Report: The final report'

  def using_views(n)
    SongRating.order(:rating).limit(n).select(:title, :artists_name, :rating)
  end

  def using_materialized_views(n)
    SongRatingsView.order(:rating).limit(n).select(:title, :artists_name, :rating)
  end

  task third: :environment do
    n = 10
    puts "\n\n\n"
    puts '--- Elapsed Time ----------------------'
    Benchmark.bmbm do |x|
      x.report('Active Record + Ruby code') { third_solution(n) }
      x.report('SQL View') { using_views(n) }
      x.report('Materialized View') { using_materialized_views(n) }
    end

    puts "\n\n\n"
    puts '--- Memory ----------------------------'
    Benchmark.memory do |x|
      x.report('Active Record + Ruby code') { third_solution(n) }
      x.report('SQL View') { using_views(n) }
      x.report('Materialized View') { using_materialized_views(n) }
      x.compare!
    end

    puts "\n\n\n"
    puts '--- Iterations per Second -------------'
    Benchmark.ips do |x|
      x.report('Active Record + Ruby code') { third_solution(n) }
      x.report('SQL View') { using_views(n) }
      x.report('Materialized View') { using_materialized_views(n) }
      x.compare!
    end
  end
end
