SELECT Name,
       AvgRating
 FROM plasma-moment-467814-r8.BoardGameGeek.games
 WHERE NumUserRatings > 500 
 ORDER BY AvgRating DESC
 LIMIT 50;