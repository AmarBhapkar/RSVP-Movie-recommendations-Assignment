USE imdb;

-- Q1. Find the total number of rows in each table of the schema?

SELECT 
    'movie' AS TableName, COUNT(*) AS rowcount
FROM
    movie 
UNION ALL SELECT 
    'genre' AS TableName, COUNT(*) AS rowcount
FROM
    genre 
UNION ALL SELECT 
    'director_mapping' AS TableName, COUNT(*) AS rowcount
FROM
    director_mapping 
UNION ALL SELECT 
    'names' AS TableName, COUNT(*) AS rowcount
FROM
    names 
UNION ALL SELECT 
    'role_mapping' AS TableName, COUNT(*) AS rowcount
FROM
    role_mapping 
UNION ALL SELECT 
    'ratings' AS TableName, COUNT(*) AS rowcount
FROM
    ratings;



-- Q2. Which columns in the movie table have null values?

SELECT 
		sum(CASE WHEN id IS NULL THEN 1
        ELSE 0
		END) AS ID_nulls,
        sum(CASE WHEN title IS NULL THEN 1
        ELSE 0
		END) AS title_nulls,
        sum(CASE WHEN year IS NULL THEN 1
        ELSE 0
		END) AS year_nulls,
        sum(CASE WHEN date_published IS NULL THEN 1
        ELSE 0
		END) AS date_published_nulls,
        sum(CASE WHEN duration IS NULL THEN 1
        ELSE 0
		END) AS duration_nulls,
        sum(CASE WHEN country IS NULL THEN 1
        ELSE 0
		END) AS country_nulls,
        sum(CASE WHEN worlwide_gross_income IS NULL THEN 1
        ELSE 0
		END) AS worlwide_gross_income_nulls,
        sum(CASE WHEN languages IS NULL THEN 1
        ELSE 0
		END) AS languages_nulls,
        sum(CASE WHEN production_company IS NULL THEN 1
        ELSE 0
		END) AS production_company_nulls
FROM  movie;     

 
 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

SELECT 
    year, COUNT(id) AS no_of_movies
FROM
    movie
GROUP BY year
ORDER BY year;

SELECT 
    month(date_published) as month_num, COUNT(id) AS no_of_movies
FROM
    movie
GROUP BY month_num
ORDER BY month_num;

  
  
-- Q4. How many movies were produced in the USA or India in the year 2019??

SELECT 
    year, COUNT(DISTINCT id) AS Movies_Produced
FROM
    movie
WHERE
    (country LIKE '%USA%'
        OR country LIKE '%India%')
        AND year = 2019;



-- Q5. Find the unique list of the genres present in the data set?

SELECT 
    genre AS genre_list
FROM
    genre
GROUP BY genre;



-- Q6.Which genre had the highest number of movies produced overall?

SELECT 
    genre, COUNT(id) AS no_of_movies
FROM
    movie AS m
        INNER JOIN
    genre AS g ON m.id = g.movie_id
GROUP BY genre
ORDER BY no_of_movies DESC
LIMIT 1;



-- Q7. How many movies belong to only one genre?

with one_genre_movies as
(
SELECT 
    movie_id
FROM 
    genre
GROUP BY 
    movie_id
HAVING 
    Count(DISTINCT genre) = 1
)
SELECT 
    COUNT(*) AS one_genre_movies
FROM
    one_genre_movies;



-- Q8.What is the average duration of movies in each genre? 

SELECT 
    genre, ROUND(AVG(duration), 2) AS avg_duration
FROM
    movie AS m
        INNER JOIN
    genre AS g ON m.id = g.movie_id
GROUP BY genre;



-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

WITH genre_rank_summary AS
(
SELECT genre, COUNT(id) as movie_count,
		RANK() OVER(ORDER BY COUNT(id) desc) AS genre_rank
FROM movie AS m
INNER JOIN genre AS g
ON m.id = g.movie_id
GROUP BY genre
)
SELECT 
    *
FROM
    genre_rank_summary
WHERE
    genre = 'thriller';



-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;



-- Q11. Which are the top 10 movies based on average rating?

WITH movie_rank_summary as
(
SELECT title, 
		avg_rating,
		DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS movie_dense_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
)
SELECT 
    *
FROM
    movie_rank_summary
WHERE
    movie_dense_rank <= 10;



-- Q12. Summarise the ratings table based on the movie counts by median ratings.

SELECT 
    median_rating, COUNT(id) AS movie_count
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
GROUP BY median_rating
ORDER BY movie_count DESC;



-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

WITH Production_company_summary AS
(
SELECT production_company, 
		count(id) AS movie_count,
		RANK() OVER(ORDER BY count(id) DESC) AS prod_company_rank
FROM movie AS m
INNER JOIN ratings AS r 
ON m.id = r.movie_id
where avg_rating > 8 AND production_company IS NOT NULL
GROUP BY production_company
)
SELECT 
	* 
FROM 
	Production_company_summary 
WHERE 
	prod_company_rank = 1;



-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

SELECT 
    genre, COUNT(id) AS movie_count
FROM
    genre AS g
        INNER JOIN
    movie AS m ON g.movie_id = m.id
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    year = 2017
        AND MONTH(date_published) = 3
        AND country = 'USA'
        AND total_votes > 1000
GROUP BY genre
ORDER BY movie_count DESC;



-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

SELECT 
    title, avg_rating, genre
FROM
    genre AS g
        INNER JOIN
    movie AS m ON g.movie_id = m.id
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    title LIKE 'The%' AND avg_rating > 8
    ORDER BY avg_rating DESC;



-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT 
    COUNT(id) AS movie_count
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    date_published BETWEEN '2018-04-01' AND '2019-04-01'
        AND median_rating = 8;



-- Q17. Do German movies get more votes than Italian movies? 

SELECT 
    country, SUM(total_votes) AS total_number_of_votes
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON r.movie_id = m.id
WHERE
    country IN ('Germany' , 'Italy')
GROUP BY country; 



-- Q18. Which columns in the names table have null values??

SELECT 
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) AS name_nulls,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) AS height_nulls,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS date_of_birth_nulls,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS known_for_movies_nulls
FROM
    names;  
            
            
            
-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

WITH Top_Three_Genre AS (
    SELECT
        genre,
        COUNT(m.id) AS Movie_count
    FROM
        movie m
    INNER JOIN
        genre g ON m.id = g.movie_id
    INNER JOIN
        ratings r ON r.movie_id = m.id
    WHERE
        avg_rating > 8
    GROUP BY
        genre
    ORDER BY
        Movie_count DESC
    LIMIT 3
)
SELECT
    n.name AS director_name,
    COUNT(m.id) AS Movie_count
FROM
    movie m
INNER JOIN
    director_mapping d ON m.id = d.movie_id
INNER JOIN
    names n ON n.id = d.name_id
INNER JOIN
    genre g ON g.movie_id = m.id
INNER JOIN
    ratings r ON m.id = r.movie_id
WHERE
    g.genre IN (SELECT genre FROM Top_Three_Genre)
    AND avg_rating > 8
GROUP BY
    director_name
ORDER BY
    Movie_count DESC
LIMIT 3;



-- Q20. Who are the top two actors whose movies have a median rating >= 8?

SELECT 
    n.name AS Actor_name, COUNT(m.id) AS Movie_count
FROM
    movie m
        INNER JOIN
    ratings r ON m.id = r.movie_id
        INNER JOIN
    role_mapping rm ON m.id = rm.movie_id
        INNER JOIN
    names n ON n.id = rm.name_id
WHERE
    median_Rating >= 8
GROUP BY Actor_name
ORDER BY Movie_count DESC
LIMIT 2;



-- Q21. Which are the top three production houses based on the number of votes received by their movies?

WITH top_production_house as
(
SELECT production_company, SUM(total_votes) AS vote_count,
		RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
GROUP BY production_company
)
SELECT
		* 
FROM 
		top_production_house 
WHERE 
		prod_comp_rank <= 3;



-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?

SELECT
      name AS actor_name,
      SUM(total_votes) AS total_votes,
      COUNT(m.id) AS movie_count,
      ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actor_avg_rating,
      ROW_NUMBER() OVER (ORDER BY  ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) DESC) AS actor_rank
FROM
    names n
INNER JOIN
    role_mapping rm 
ON n.id = rm.name_id
INNER JOIN
    ratings r 
ON rm.movie_id = r.movie_id
INNER JOIN
    movie m 
ON m.id = rm.movie_id
WHERE
    category = "actor"
    AND country LIKE "%india%"
GROUP BY
    actor_name
HAVING
    movie_count >= 5;



-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 

SELECT
      name AS actress_name,
      SUM(total_votes) AS total_votes,
      COUNT(m.id) AS movie_count,
      ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actress_avg_rating,
      ROW_NUMBER() OVER (ORDER BY  ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) DESC) AS actress_rank
FROM
    names n
INNER JOIN
    role_mapping rm 
ON n.id = rm.name_id
INNER JOIN
    ratings r 
ON rm.movie_id = r.movie_id
INNER JOIN
    movie m 
ON m.id = rm.movie_id
WHERE
    category = "actress"
    AND country LIKE "%india%"
    AND languages LIKE "%hindi%"
GROUP BY
    actress_name
HAVING
    movie_count >= 3;



/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

select title,
		avg_rating,
        case 
        when avg_rating > 8 then 'Superhit movie'
        when avg_rating between 7 and 8 then 'Hit movie'
        when avg_rating between 5 and 7 then 'One-time-watch movie'
        when avg_rating < 5 then 'Flop movie'
        end as avg_rating_catehory   
FROM
    movie AS m
INNER JOIN
    genre AS g ON m.id = g.movie_id
INNER JOIN
    ratings AS r ON r.movie_id = m.id
WHERE
    genre = 'Thriller';      



-- Q25. Which are the five highest-grossing movies of each year that belong to the top three genres? 

WITH top_three_genre AS
(SELECT
        genre,
        COUNT(m.id) AS movie_count
    FROM
        movie m
    INNER JOIN
        genre g ON g.movie_id = m.id
    GROUP BY
        genre
    ORDER BY
        movie_count DESC
    LIMIT 3),
five_highest_grossing_movies AS 
(SELECT 
      g.genre,
      m.Year,
      m.title AS movie_name,
      m.worlwide_gross_income,
	  ROW_NUMBER() OVER (PARTITION BY m.year ORDER BY worlwide_gross_income DESC) AS movie_rank
FROM 
      movie AS m 
INNER JOIN 
	  genre g 
ON g.movie_id = m.id      
WHERE
     g.genre IN (SELECT genre FROM top_three_genre))
SELECT
    *
FROM
    five_highest_grossing_movies
WHERE
    movie_rank <= 5;



-- Q26. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

SELECT 
      name AS actress_name,
      SUM(total_votes) AS total_votes,
      COUNT(m.id) AS movie_count,
      AVG(avg_rating) AS actress_avg_rating,
	  ROW_NUMBER() OVER (ORDER BY count(m.id) DESC) AS actress_rank
FROM
    names n
INNER JOIN
    role_mapping rm ON n.id = rm.name_id
INNER JOIN
    movie m ON m.id = rm.movie_id
INNER JOIN
    ratings r ON r.movie_id = m.id
INNER JOIN
    genre g ON g.movie_id = m.id
WHERE
    avg_rating > 8
    AND category = "actress"
    AND genre = "drama"
GROUP BY
    actress_name
LIMIT 3;







