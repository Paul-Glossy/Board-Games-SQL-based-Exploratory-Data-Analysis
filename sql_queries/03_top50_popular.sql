SELECT Name,
       NumOwned+NumWant+NumWish AS popularity -- aggregate the numbers of users who already own, want or add game into wishlist as a popularity metric
 FROM plasma-moment-467814-r8.BoardGameGeek.games
 ORDER BY popularity DESC
 LIMIT 50;