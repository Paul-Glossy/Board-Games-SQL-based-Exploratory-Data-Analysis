SELECT
  *
FROM
  (
    SELECT
      'Top Tier' AS game_tier,
      Name,
      `Rank:boardgame`,
      AvgRating
    FROM
      `plasma-moment-467814-r8.BoardGameGeek.games`
    WHERE
      -- Filtering for games in the top 100 ranks.
      `Rank:boardgame` <= 100
    ORDER BY
      -- Sorting by AvgRating to get the best-rated games.
      AvgRating DESC
    LIMIT 20
  )
UNION ALL
SELECT
  *
FROM
  (
    SELECT
      'Bottom Tier' AS game_tier,
      Name,
      `Rank:boardgame`,
      AvgRating
    FROM
      `plasma-moment-467814-r8.BoardGameGeek.games`
    WHERE
      -- Using a high rank to capture the lowest-ranked games.
      `Rank:boardgame` >= 15000
    ORDER BY
      -- Sorting by AvgRating to find the absolute worst-rated games.
      AvgRating ASC
    LIMIT 20
  );