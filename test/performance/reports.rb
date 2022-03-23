require "test_helper"

require "benchmark"
require "benchmark-memory"
require "benchmark/ips"

class ReportsTest < ActiveSupport::TestCase
  test "first report" do
    def first_solution
      Album.includes(:ratings).map { |album| album.ratings.length }.max
    end

    def second_solution
      Album.from(Album.select(
        "albums.*", "COUNT(ratings.id) AS rating_count"
      ).joins(:ratings).group("albums.id")).maximum("rating_count")
    end

    puts "--- Elapsed Time ----------------------"
    Benchmark.bmbm do |x|
      x.report("Active Record + Ruby code") { first_solution }
      x.report("Only Active Record") { second_solution }
    end

    puts "--- Memory ----------------------------"
    Benchmark.memory do |x|
      x.report("Active Record + Ruby code") { first_solution }
      x.report("Only Active Record") { second_solution }
      x.compare!
    end

    puts "--- Iterations per Second -------------"
    Benchmark.ips do |x|
      x.report("Active Record + Ruby code") { first_solution }
      x.report("Only Active Record") { second_solution }
      x.compare!
    end
  end

  test "second report" do
    def first_solution(n)
      p "first_solution(#{n})"
      ratings = Rating
        .where(votable_type: "Song")
        .group(:votable_id).average(:vote)
        .sort_by(&:last).take(n).to_h
      p "first_solution(#{n}) => #{User.count}"
      songs = Song.includes(:artists).find(ratings.keys)
      ratings.map do |song_id, rating|
        song = songs.find { |song| song.id == song_id }
        {
          song: song.title,
          artist: song.artists.map(&:name).join(", "),
          rating_avg: rating
        }
      end
    end

    def second_solution(n)
      Song
        .includes(:artists).joins(:ratings)
        .select("songs.*, AVG(ratings.vote) as rating_avg")
        .group("songs.id").order("rating_avg DESC").limit(n)
        .map do |song|
          {
            song: song.title,
            artist: song.artists.map(&:name).join(", "),
            rating_avg: song.rating_avg
          }
        end
    end

    def third_solution(n)
      ratings = Rating
        .select("ratings.votable_id, AVG(ratings.vote) as rating_avg")
        .where(votable_type: "Song")
        .group(:votable_id).order("rating_avg DESC").limit(n)
      Song.includes(:artists).find(ratings.map(&:votable_id)).map do |song|
        {
          song: song.title,
          artist: song.artists.map(&:name).join(", "),
          rating_avg: ratings.find { |rating| rating.votable_id == song.id }.rating_avg
        }
      end
    end

    p first_solution(10)
    p second_solution(10)
    p third_solution(10)

    def measure(n)
      puts "--- Elapsed Time ----------------------"
      Benchmark.bmbm do |x|
        x.report("Active Record + Ruby code") { first_solution(n) }
        x.report("Only Active Record") { second_solution(n) }
        x.report("Active Record + Ruby code v2") { third_solution(n) }
      end

      puts "--- Memory ----------------------------"
      Benchmark.memory do |x|
        x.report("Active Record + Ruby code") { first_solution(n) }
        x.report("Only Active Record") { second_solution(n) }
        x.report("Active Record + Ruby code v2") { third_solution(n) }
        x.compare!
      end

      puts "--- Iterations per Second -------------"
      Benchmark.ips do |x|
        x.report("Active Record + Ruby code") { first_solution(n) }
        x.report("Only Active Record") { second_solution(n) }
        x.report("Active Record + Ruby code v2") { third_solution(n) }
        x.compare!
      end
    end

    # measure(10)
  end
end
