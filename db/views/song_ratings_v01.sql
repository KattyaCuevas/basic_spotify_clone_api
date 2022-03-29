SELECT
	songs_ratings.id AS id,
	songs_ratings.title AS title,
	songs_ratings.rating AS rating,
	albums.id AS album_id,
	albums.title AS album_title,
	artists.id AS artist_id,
	artists.name AS artists_name
FROM (
	SELECT
		songs.id AS id,
		songs.title AS title,
		AVG(ratings.vote) AS rating
	FROM
		ratings
		JOIN songs ON ratings.votable_id = songs.id
	WHERE
		ratings.votable_type = 'Song'
	GROUP BY
		ratings.votable_id,
		songs.id) AS songs_ratings
JOIN association ON association.song_id = songs_ratings.id
JOIN albums ON association.album_id = albums.id
JOIN artists ON association.artist_id = artists.id