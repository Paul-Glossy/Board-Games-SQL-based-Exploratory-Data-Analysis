WITH GameData AS (
  SELECT
    Name,
    AvgRating,
    (NumOwned + NumWant + NumWish) AS popularity_score
  FROM
    `plasma-moment-467814-r8.BoardGameGeek.games`
  WHERE
    -- Filters for games that could be either underrated or overrated
    (AvgRating >= 8.0 AND (NumOwned + NumWant + NumWish) < 500)
    OR
    (AvgRating <= 5.0 AND (NumOwned + NumWant + NumWish) > 5000)
    AND NumUserRatings > 100 -- Ensures games have a minimum number of ratings
)
SELECT
  Name,
  AvgRating,
  popularity_score,
  CASE
    WHEN AvgRating >= 8.0 THEN 'Underrated'
    WHEN AvgRating <= 5.0 THEN 'Overrated'
  END AS status,
  -- Calculate a custom ratio to rank the games
  CASE
    WHEN AvgRating >= 8.0 THEN (AvgRating / popularity_score)
    WHEN AvgRating <= 5.0 THEN (popularity_score / AvgRating)
  END AS ranking_score
FROM
  GameData
ORDER BY
  -- Use a CASE statement to sort each group by its respective score
  CASE
    WHEN AvgRating >= 8.0 THEN (AvgRating / popularity_score)
    WHEN AvgRating <= 5.0 THEN (popularity_score / AvgRating)
  END DESC
LIMIT 20;