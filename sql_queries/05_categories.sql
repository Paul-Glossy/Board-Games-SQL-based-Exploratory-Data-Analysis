SELECT
  category_name,
  COUNT(BGGId) AS games_count,
  AVG(NumOwned + NumWant + NumWish) AS avg_popularity,
  AVG(AvgRating) AS avg_rating
FROM
  `plasma-moment-467814-r8.BoardGameGeek.games`
UNPIVOT(
  is_in_category FOR category_name IN (
    `Cat:Thematic`, `Cat:Strategy`, `Cat:War`, `Cat:Family`,
    `Cat:CGS`, `Cat:Abstract`, `Cat:Party`, `Cat:Childrens`
  )
)
WHERE
  is_in_category = 1
  AND NumUserRatings > 100
GROUP BY
  category_name
ORDER BY
  games_count DESC;