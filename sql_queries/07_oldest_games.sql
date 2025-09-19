SELECT
  Name,
  yearPublished,
  ROUND(AvgRating,1) AS rating, 
  (NumOwned + NumWant + NumWish) AS popularity_score
FROM
  `plasma-moment-467814-r8.BoardGameGeek.games`
WHERE
  NumUserRatings > 500  -- Filter for well-known games
  AND yearPublished != 0 -- Filtering out zeros because our dataset contains games without known yearPublished as "0"
  AND yearPublished < 1000 -- Filtering for year published 
ORDER BY
  yearPublished ASC
LIMIT 10;