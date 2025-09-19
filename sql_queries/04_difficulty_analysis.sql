SELECT 
       CASE WHEN GameWeight <= 2 THEN "simple"
            WHEN GameWeight > 2 AND GameWeight <= 3 THEN "medium"
            ELSE "hard" END AS difficulty, -- labeling games by difficulty ratings on a scale 0 to 5 into "simple", 'medium' and 'hard'
       CAST(ROUND(AVG(NumOwned+NumWant+NumWish),0) AS INT64) AS avg_popularity, -- avg rating for each difficulty, applying CAST and ROUND to get rid of decimals
       ROUND(AVG(AvgRating),1) AS avg_rating, -- avg rating for each difficulty
       COUNT(BGGId) AS count -- number of games of each difficulty
 FROM plasma-moment-467814-r8.BoardGameGeek.games
 WHERE NumUserRatings > 100 -- decided to filtering out "homebrew" or unpublished games with less then 100 user ratings
 GROUP BY difficulty
 ORDER BY count DESC