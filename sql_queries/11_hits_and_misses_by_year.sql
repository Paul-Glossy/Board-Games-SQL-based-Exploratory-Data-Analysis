SELECT
  T1.Name AS Game_High_Rated,
  T1.AvgRating AS Game_High_Rated_Score,
  T1.NumOwned AS Game_High_Rated_Owned,
  T2.Name AS Game_Popular_Low_Rated,
  T2.AvgRating AS Game_Low_Rated_Score,
  T2.NumOwned AS Game_Low_Rated_Owned,
  T1.yearPublished
FROM
  `plasma-moment-467814-r8.BoardGameGeek.games` AS T1
JOIN
  `plasma-moment-467814-r8.BoardGameGeek.games` AS T2
ON
  T1.yearPublished = T2.yearPublished
WHERE
  T1.BGGId < T2.BGGId -- Ensures each pair is listed only once
  AND T1.yearPublished BETWEEN 2010 AND 2020 -- Focuses on the "golden era"
  AND T1.AvgRating > 8.0 AND T2.AvgRating < 6.0 -- One game is highly-rated, the other is not
  AND ABS(T1.NumOwned - T2.NumOwned) > 5000 -- The two games have a significant difference in popularity
ORDER BY
  T1.yearPublished DESC
LIMIT 50;