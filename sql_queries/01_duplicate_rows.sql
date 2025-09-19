SELECT BGGid,
       COUNT(*)
 FROM plasma-moment-467814-r8.BoardGameGeek.games 
 GROUP BY
       BGGid
HAVING
    COUNT(*) > 1 -- Filtering data after grouping to find out is there are any duplicates in BGGid