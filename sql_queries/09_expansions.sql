SELECT
  CASE
    WHEN NumExpansions > 0 THEN 'Has Expansions'
    ELSE 'No Expansions'
  END AS expansion_status,
  COUNT(BGGId) AS total_games,
  ROUND(AVG(AvgRating), 2) AS avg_rating,
  CAST(ROUND(AVG(NumOwned + NumWant + NumWish), 0) AS INT64) AS avg_popularity
FROM
  `plasma-moment-467814-r8.BoardGameGeek.games`
WHERE
  NumUserRatings > 100
GROUP BY
  expansion_status;