WITH UnpivotedPublishers AS (
  SELECT
    BGGId,
    publisher_name
  FROM
    `plasma-moment-467814-r8.BoardGameGeek.publishers`
  UNPIVOT(
  is_publisher FOR publisher_name IN (
    `Hasbro`, `Asmodee`, `Ravensburger`, `Pegasus Spiele`, `Korea Boardgames Co__ Ltd_`,
    `KOSMOS`, `Hobby World`, `Edge Entertainment`, `Rio Grande Games`, `Milton Bradley`
  )
  )
  WHERE
    is_publisher = 1
)
SELECT
  T1.publisher_name,
  T2.Name,
  (T2.NumOwned + T2.NumWant + T2.NumWish) AS avg_popularity,
  ROW_NUMBER() OVER(PARTITION BY T1.publisher_name ORDER BY (T2.NumOwned + T2.NumWant + T2.NumWish) DESC) AS popularity_rank
FROM
  UnpivotedPublishers AS T1
JOIN
  `plasma-moment-467814-r8.BoardGameGeek.games` AS T2
ON
  T1.BGGId = T2.BGGId
WHERE
  T1.publisher_name IN (
    'Hasbro', 
    'Asmodee', 
    'Ravensburger',
    'Pegasus Spiele',
    'Korea Boardgames Co__ Ltd_',
    'KOSMOS',
    'Hobby World',
    'Edge Entertainment',
    'Rio Grande Games',
    'Milton Bradley'
  )
  AND T2.NumUserRatings > 100
QUALIFY
  ROW_NUMBER() OVER(PARTITION BY T1.publisher_name ORDER BY (T2.NumOwned + T2.NumWant + T2.NumWish) DESC) <= 10
ORDER BY
  T1.publisher_name, popularity_rank;