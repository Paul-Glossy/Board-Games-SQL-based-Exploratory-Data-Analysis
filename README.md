# SQL Portfolio Project: Board Games Analysis
![](/images/main.jpg)
## Project Overview
This project demonstrates SQL skills by analyzing board games data from BoardGameGeek - online forum for board gaming hobbyists and a game database that holds reviews, images and ratings for over 125,600 different tabletop games, including European-style board games, wargames, and card games.

**Business Question:** A local online store wants to expand into the board games product segment. I was asked to research the current market and provide a starting strategy and recommendations (e.g., which games to stock at first, which genres and publishers are most popular, and whether ratings correlate with sales).

**Technical Goal:** To perform an Exploratory Data Analysis (EDA) of the current board game market by exploring trends, relationships, and statistics using SQL queries in BigQuery.

- **Dataset:** BoardGameGeek CSV files from Kaggle (https://www.kaggle.com/datasets/threnjen/board-games-database-from-boardgamegeek)
- **Tools:** BigQuery, SQL
- **Focus Areas:** Cleaning, aggregations, filtering, joins, ordering, grouping, analytical functions

---

## Dataset Overview
The dataset contains 8 tables with a star schema and many-to-many relations. The main table is "games" with the primary key `BGGid` (game ID), and it is related to tables for artists, designers, mechanics, publishers, ratings, subcategories, and themes.

---

## Table of Contents
1. [Question 1: Check the main table for duplicate rows](#question-1-check-the-main-table-for-duplicate-rows)
2. [Question 2: Find the top 50 highest-rated board games](#question-2-find-the-top-50-highest-rated-board-games)
3. [Question 3: Find 50 most popular board games](#question-3-find-50-most-popular-board-games)
4. [Question 4: Do people prefer harder games or easier? And which of them get a higher rating?](#question-4-do-people-prefer-harder-games-or-easier-and-which-of-them-get-higher-rating)
5. [Question 5: Find out which category of games is most popular/highly rated](#question-5-find-out-which-category-of-games-is-most-popularhighly-rated)
6. [Question 6: Find Top 10 publishers and 10 most popular games for each of them](#question-6-find-top-10-publishers-and-10-most-popular-games-for-each-of-them)
7. [Question 7: What are the oldest games in the dataset that are still widely rated?](#question-7-what-are-the-oldest-games-in-the-dataset-that-are-still-widely-rated)
8. [Question 8: How has the number of games published and their average rating changed over time?](#question-8-how-has-the-number-of-games-published-and-their-average-rating-changed-over-time)
9. [Question 9: The Expansion Effect on Popularity and Ratings](#question-9-the-expansion-effect-on-popularity-and-ratings)
10. [Question 10: A Tale of Two Tiers: Finding best and worst games](#question-10-a-tale-of-two-tiers-finding-best-and-worst-games)
11. [Question 11: Best and worst hits from the same year](#question-11-best-and-worst-hits-from-the-same-year)
12. [Question 12: What is the most underrated and overrated board games?](#question-12-what-is-the-most-underrated-and-overrated-board-games)
13. [Conclusion](#conclusion)

---

## Question 1: Check the main table for duplicate rows

**SQL Query:**
```sql
SELECT BGGid,
    COUNT(*)
 FROM plasma-moment-467814-r8.BoardGameGeek.games
 GROUP BY
    BGGid
 HAVING
    COUNT(*) > 1 -- Filtering data after grouping to find out if there are any duplicates in BGGid
```
**Output**:
![Query output showing no duplicate rows](/images/01_duplicates.jpg)

## Question 2: Find the top 50 highest-rated board games

**SQL Query:**
```sql
SELECT Name,
       AvgRating
 FROM plasma-moment-467814-r8.BoardGameGeek.games
 WHERE NumUserRatings > 500 -- filtering out games with less then 500 ratings to make sure there are no homebrew or unpublished items
 ORDER BY AvgRating DESC
 LIMIT 50;
```
**Output**:
![Top 50 games by rating](/images/02_top50_rating.jpg)

## Question 3: Find 50 most popular board games

**SQL Query:**
```sql
SELECT Name,
       NumOwned+NumWant+NumWish AS popularity -- aggregate the numbers of users who already own, want or add game into wishlist as a popularity metric
 FROM plasma-moment-467814-r8.BoardGameGeek.games
 ORDER BY popularity DESC
 LIMIT 50;
```

**Output**:
![Top 50 games by popularity](/images/03_top50_popularity.jpg)

## Question 4: Do people prefer harder games or easier? And which of them get a higher rating?

**SQL Query:**
```sql
SELECT 
       CASE WHEN GameWeight <= 2 THEN "simple"
            WHEN GameWeight > 2 AND GameWeight <= 3 THEN "medium"
            ELSE "hard" END AS difficulty, 
            -- labeling games by difficulty ratings on a scale 0 to 5 into "simple", 'medium' and 'hard'
       CAST(ROUND(AVG(NumOwned+NumWant+NumWish),0) AS INT64) AS avg_popularity, 
       -- avg popularity for each difficulty, applying CAST and ROUND to get rid of decimals
       ROUND(AVG(AvgRating),1) AS avg_rating, -- avg rating for each difficulty
       COUNT(BGGId) AS count -- number of games of each difficulty
 FROM plasma-moment-467814-r8.BoardGameGeek.games
 WHERE NumUserRatings > 100 
 -- Filtering out games with less than 100 user ratings
 GROUP BY difficulty
 ORDER BY count DESC
```
**Output**:
![Difficulty analysis](/images/04_difficulty_analysis.jpg)

**Key Findings:**
- **Popularity Increases with Difficulty**: Games categorized as "hard" have the highest average popularity score, indicating that more complex games tend to attract a larger number of dedicated followers.

- **Higher Ratings for Harder Games**: The average rating steadily increases from "simple" to "hard" games, suggesting that while complex games may appeal to a smaller audience, they are often more highly rated by their players.

- **Market Dominance of Simple Games**: The number of games in the "simple" category is significantly higher than in the "hard" category. This reveals that most games released are designed for a broader, more casual audience.
These insights show a clear trend: the more complex and niche a board game is, the more likely it is to be highly rated and popular among its target audience, despite fewer such games being produced overall.

## Question 5: Find out which category of games is most popular/highly rated

**SQL Query:**
```sql
SELECT
  category_name,
  COUNT(BGGId) AS games_count,
  CAST(AVG(NumOwned + NumWant + NumWish) AS INT64) AS avg_popularity,
  ROUND(AVG(AvgRating),1) AS avg_rating
FROM
  `plasma-moment-467814-r8.BoardGameGeek.games`
UNPIVOT(
  is_in_category FOR category_name IN (
    `Cat:Thematic`, `Cat:Strategy`, `Cat:War`, `Cat:Family`,
    `Cat:CGS`, `Cat:Abstract`, `Cat:Party`, `Cat:Childrens`
  ) -- The UNPIVOT clause transforms wide data into a single 'category_name' column.
)
WHERE
  is_in_category = 1 -- Filters to show only games belonging to a category
  AND NumUserRatings > 100
GROUP BY
  category_name
ORDER BY
  games_count DESC;
```
**Output**:
![Best games by category](/images/05_categories.jpg)

**SQL visualisation**:
![](/images/05_categories_viz.jpg)

The query results provide a clear overview of the board game market, revealing distinct patterns across different categories.

**Market Dominance and Popularity**: The Strategy and Family categories have the largest number of games (2221 and 2220 respectively), confirming their status as the most produced and widespread genres. These two categories are also the most popular, with very high average popularity scores. The War category is also significant in terms of game count but has a much lower average popularity, suggesting it appeals to a smaller, more dedicated niche.

**Niche Popularity**: The Party and Card Game (CGS) categories are particularly notable. Despite having a limited number of games (621 and 219), they boast high average popularity scores (4955 and 3553). This indicates that while they are not as common as strategy or family games, the ones that are published are highly sought after by their target audience.

**Rating vs. Popularity**: The average ratings show a nuanced picture. Strategy and War games have the highest average ratings (7.0), suggesting they are highly valued by their players. In contrast, Children's games have the lowest count and lowest average popularity and rating, which may reflect their simpler design and target audience.

## Question 6: Find Top 10 publishers and 10 most popular games for each of them
**Objective:** Find Top10 publishers and 10 most popular games for each of them. Since the publishers table is in a wide format, an initial step was taken to identify the top 10 publishers by the number of games released using a spreadsheet.

**SQL Query:**
```sql
-- CTE 1: UnpivotedPublishers
-- This CTE transforms the wide 'publishers' table into a tall, usable format.
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
),
-- CTE 2: RankedGames
-- This CTE joins the publisher information with the game data and applies a ranking.
RankedGames AS (
  SELECT
    T1.publisher_name,
    T2.Name,
    (T2.NumOwned + T2.NumWant + T2.NumWish) AS avg_popularity,
-- The window function ROW_NUMBER() is used here for ranking.
-- PARTITION BY publisher_name: tells the function to restart the count for each new publisher.
-- ORDER BY avg_popularity DESC: sorts the games by popularity to assign ranks from 1 (most popular) to N.
    ROW_NUMBER() OVER(PARTITION BY T1.publisher_name ORDER BY (T2.NumOwned + T2.NumWant + T2.NumWish) DESC) AS popularity_rank
  FROM
    UnpivotedPublishers AS T1
-- LEFT JOIN connects the publishers to the games table using BGGId.
-- A LEFT JOIN is chosen to ensure we keep all publisher entries, even if a game has no
-- corresponding data in the 'games' table (though our WHERE clause will filter those out).
  LEFT JOIN
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
)
-- Final SELECT statement
SELECT
  publisher_name,
  Name,
  avg_popularity,
  popularity_rank
FROM
  RankedGames
WHERE
  popularity_rank <= 10
ORDER BY
  publisher_name, popularity_rank;
```

**Output**:
![Best games by publishers](/images/06_publishers.jpg)

With the help of a spreadsheet, we found the top 10 game publishers by number of games released. Then, using two CTEs, a JOIN, and a window function, we found the 10 most popular games ever released from each of these top publishers. Knowing the best publishers and their most popular products is a great business opportunity to connect with them, find good prices, and create strong partnership relations for the future.

## Question 7: What are the oldest games in the dataset that are still widely rated?

**SQL Query:**
```sql
SELECT
  Name,
  yearPublished,
  ROUND(AvgRating,1) AS rating, 
  (NumOwned + NumWant + NumWish) AS popularity_score
FROM
  `plasma-moment-467814-r8.BoardGameGeek.games`
WHERE
  NumUserRatings > 500  
  -- Filter for well-known games
  AND yearPublished != 0 
  -- Filtering out games with an unknown publication year
  AND yearPublished < 1000 
  -- Filtering for old games
ORDER BY
  yearPublished ASC
LIMIT 10;
```

**Output**:
![Oldest games](/images/07_oldest_games.jpg)

An oldest and well-known games. We could use this for a marketing campaign titled "The Board Game Hall of Fame" or "Ancient Classics."

## Question 8: How has the number of games published and their average rating changed over time?
**Objective:** Finding The "Golden Era" of board games.

**SQL Query:**
```sql
SELECT
-- FLOOR() is used here to group games by decade. 
  FLOOR(yearPublished / 10) * 10 AS decade,
  COUNT(BGGId) AS games_published,
  ROUND(AVG(AvgRating), 2) AS avg_rating,
  CAST(ROUND(AVG(NumOwned + NumWant + NumWish), 0) AS INT64) AS avg_popularity
FROM
  `plasma-moment-467814-r8.BoardGameGeek.games`
WHERE
 yearPublished > 0
GROUP BY
  decade
HAVING COUNT(BGGId) > 100
ORDER BY
  decade;
```

**Output**:
![Games trending](/images/08_decade_research.jpg)

The query results provide compelling insights into the growth and evolution of the board game industry. The data shows a clear and accelerating trend in both the quantity and quality of games published.

- **Exponential Growth**: The number of games published has grown exponentially, particularly since the turn of the century. The number of games published in the 2010s (10,721) is more than double that of the 2000s (4,713), highlighting a massive boom in the hobby.

- **The Modern Golden Era**: The most significant insight is that the period from the 2010s to the present day represents a "Modern Golden Era" for board gaming. While the number of games published peaked in the 2010s, the average ratings have consistently risen, reaching a new high of 7.34 in the 2020s. Because our dataset only contains partial data for the 2020s, it's unreasonable to compare the decades directly. However, the upward trend in both quantity and quality strongly indicates that the market is not only growing but also maturing, with a focus on high-quality games.

- **Business Implications**: This data shows that the board gaming hobby is currently trending and highly engaged. For your business, this segment is a prime target for expansion. Focusing on games from the 2010s and beyond, particularly those with high ratings and popularity, would be a sound strategy to attract and retain a growing customer base.

## Question 9: The Expansion Effect on Popularity and Ratings
**Objective:** The "Expansion Effect" on Popularity and Ratings. This query tests the hypothesis that a game's success leads to expansions, rather than the other way around.

**SQL Query:**
```sql
SELECT
  CASE
    WHEN NumExpansions > 0 THEN 'Has Expansions'
    ELSE 'No Expansions'
  END AS expansion_status,
  COUNT(BGGId) AS total_games,
  ROUND(AVG(AvgRating), 2) AS avg_rating,
  CAST(ROUND(AVG(NumOwned + NumWant + NumWish), 0) AS INT64) AS avg_popularity
FROM
  `plasma-moment-467814-r8.BoardGameGeek.games`
WHERE
  NumUserRatings > 100
GROUP BY
  expansion_status;
```

**Output**:
![Expansion effect](/images/09_expansions.jpg)

The results of the query clearly confirm that games with expansions are significantly more successful. They are not only more popular but also receive higher ratings from the community.

**Popularity**: Games with expansions are over 3.5 times more popular (5522 vs. 1559, respectively).

**Quality**: They have higher average rating also (6.95 vs. 6.38).

**Key Business Insights**:

- **Inventory Prioritization**: Prioritize stocking games that have expansions. These games have already proven their demand and will be reliable bestsellers in your store's catalog.

- **Marketing**: Create themed collections like "Bestsellers: Games with Expansions" or run promotions on "base game + expansion" bundles, which can become a core element of our sales strategy.

## Question 10: A Tale of Two Tiers: Finding best and worst games

**SQL Query:**
```sql
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
      `Rank:boardgame` >= 15000
    ORDER BY
      AvgRating ASC
    LIMIT 20
  );
```

**Output**:
![Best and worst games](/images/10_best_and_worst.jpg)

The use of subqueries here is a workaround for the limitations of UNION ALL. In standard SQL, you cannot directly apply ORDER BY and LIMIT to individual queries that are part of a UNION or UNION ALL statement. The database expects a single ORDER BY at the very end of the combined result set.
By enclosing each SELECT statement in parentheses and treating it as a subquery, we effectively create a temporary, ordered, and limited table.

Knowing what the community actively dislikes or considers a joke is just as important as knowing what it loves. It allows us to:
- **Avoid Poor Inventory Choices**: By steering clear of these low-rated, "hated" games, we can protect our store's reputation and avoid stocking products that are unlikely to sell.

- **Create Engaging Content**: We could use this data to write blog posts or create social media content around "The Most Hated Board Games of All Time" or "Games So Bad They're Good," which can drive traffic to your site. 
The presence of games like "Rock Paper Scissors Game" and, particularly, "The Twilight Saga: New Moon" on our "hated" list shows that we manage to effectively capturing community sentiment — including the negative and meme-driven aspects.

## Question 11: Best and worst hits from the same year
**Objective:** Best and worst "hits" from the same year. This query uses a SELF JOIN to find pairs of games from the same year with a significant difference in rating and ownership.

**SQL Query:**
```sql
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
```

**Output**:
![Hits and misses by year](/images/11_hits_and_misses_by_year.jpg)

## Question 12: What is the most underrated and overrated board games?

**SQL Query:**
```sql
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
```
**Output**:
![Most underrated and overrated games](/images/12_underrated_overrated.jpg)

## Conclusions

1. **Business Findings and Recommendations** 📈
Based on our exploratory data analysis, we have uncovered several key insights and strategic recommendations for an online store looking to expand into the board games market.

- **The Modern Golden Era**: The board game market is currently thriving, with a massive and accelerating increase in the volume and quality of new games published since 2010. This indicates a highly engaged and growing customer base, making now an ideal time to enter the market. Our store's strategy should focus heavily on stocking and promoting games from this "Modern Golden Era" to attract this audience.

- **Targeting the Niche for Profit**: While "simple" games are the most numerous, more complex games attract a dedicated and highly satisfied audience, evidenced by their higher average ratings. By focusing on Strategy and War games, we can target a passionate niche, which may lead to higher-value purchases and strong customer loyalty.

- **The Expansion Effect**: Our analysis shows a strong correlation between a game having expansions and its overall popularity and high rating. This suggests that expansions are a key part of the modern gaming business model. We should prioritize stocking games that have existing expansions and use them as a cornerstone of our cross-selling strategy, offering bundles of base games with their expansions.

- **Ready-to-Go Starting Stock**: Our queries, particularly those identifying top games by rating, popularity, and category, have generated a ready-to-go list of best-sellers. This provides a practical and immediate benefit for the stakeholder. By starting with a diversified stock of games that are already proven hits across various categories, the store can appeal to different audience segments from day one and build a strong foundation.

- **Data-Driven Marketing and Content**: We can leverage our findings to create compelling marketing content. By highlighting "timeless classics" and "hidden gems" (underrated games), and even creating content around "hated" games to spark discussion, we can drive traffic and establish our store as a knowledgeable resource within the community.

2. **Technical Skills Demonstrated** 💻
This project was a comprehensive exercise in using advanced SQL to transform raw data into actionable business intelligence. The analysis demonstrated proficiency in several key areas:

- **Data Aggregation and UNPIVOT**: We used GROUP BY and aggregate functions (COUNT, AVG, SUM) to summarize key metrics. A core technical challenge was solved by using the UNPIVOT clause to transform wide data tables (for categories and publishers) into a manageable format for analysis.

- **Complex Joins and Subqueries**: We leveraged LEFT JOIN to connect datasets and a SELF JOIN to compare games from the same publication year. The project also showcased the use of subqueries within WHERE clauses and UNION ALL statements to filter data dynamically and combine results from different tiers.

- **Window Functions**: The use of a ROW_NUMBER() window function within a CTE was critical for ranking games by popularity for each publisher. This allowed us to find the top games for a specific group, a common analytical task.

- **Logical Conditionals**: CASE statements were used extensively to categorize games by difficulty and to create custom metrics and rankings, such as the ranking_score for identifying overrated and underrated games.

In summary, this project highlights a most of the fundamentals of SQL and some advanced techniques, demonstrating the ability to clean, prepare, and analyze complex datasets to drive business strategy.
=======
# Board-Games-SQL-based-Exploratory-Data-Analysis
A SQL-based data analysis of the BoardGameGeek dataset, demonstrating a range of technical skills. The project provides key business insights and actionable recommendations for an online store entering the board game market.
