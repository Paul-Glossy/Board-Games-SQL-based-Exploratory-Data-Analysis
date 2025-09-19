SELECT
-- FLOOR() is used here to group games by decade. 
-- It truncates the year to the nearest 10, for example 2017 becomes 2010.
  FLOOR(yearPublished / 10) * 10 AS decade,
  COUNT(BGGId) AS games_published,
  ROUND(AVG(AvgRating), 2) AS avg_rating,
  CAST(ROUND(AVG(NumOwned + NumWant + NumWish), 0) AS INT64) AS avg_popularity
FROM
  `plasma-moment-467814-r8.BoardGameGeek.games`
WHERE
 yearPublished > 0
GROUP BY
  decade
HAVING COUNT(BGGId) > 100
ORDER BY
  decade;