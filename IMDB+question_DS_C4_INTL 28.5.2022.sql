USE imdb;
/* Problem Statement
The RSVP company would like to expand its market globally. 
The data-driven strategy is used to help the company succeed in its new project. 
The analysis of retrospective data and recommendations is provided as follows. */

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables. */

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
/* Answer: movies 7997 rows, genre 14662, director_mapping 3867, 
names 25735, ratings 7997, role_mapping 15615 */

SELECT COUNT(*) AS rows_movies FROM movie;
SELECT COUNT(*) AS rows_genre FROM genre;
SELECT COUNT(*) AS rows_director FROM director_mapping;
SELECT COUNT(*) AS rows_names FROM names;
SELECT COUNT(*) AS rows_ratings FROM ratings;
SELECT COUNT(*) AS rows_role FROM role_mapping;


-- Q2. Which columns in the movie table have null values?
-- Type your code below:
-- Answer : country, worlwide_gross_income, languages, production_company

SELECT DISTINCT CASE WHEN id IS NULL THEN 'id'
			WHEN title IS NULL THEN 'title'
            WHEN year IS NULL THEN 'year'
            WHEN date_published IS NULL THEN 'date_published'
            WHEN duration IS NULL THEN 'duration'
            WHEN country IS NULL THEN 'country'
            WHEN worlwide_gross_income IS NULL THEN 'worldwide_gross_income'
            WHEN languages IS NULL THEN 'Languages'
            WHEN production_company IS NULL THEN 'production_company'
            END AS columns_with_null
FROM movie
HAVING columns_with_null IS NOT NULL;

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
/* Answer: From the year 2017 to 2019, the number of movies produced decreased.
The peak month that had the highest number of movies produced was March. */

SELECT year AS Year,
		COUNT(title) AS number_of_movies
FROM movie
GROUP BY year
ORDER BY year;

SELECT MONTH(date_published) AS month_num,
		COUNT(title) AS number_of_movies
FROM movie
GROUP BY month_num
ORDER BY month_num;

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
-- Answer: India-309, USA-750 

WITH usa_india AS (
SELECT id,
		CASE WHEN POSITION('India' IN country)>0 THEN 'India'
			WHEN POSITION('USA' IN country)>0 THEN 'USA'
            END AS target_country
FROM movie
WHERE year = 2019)
SELECT target_country,
		COUNT(id) AS number_of_movies
FROM usa_india
WHERE target_country = 'india'
		OR target_country = 'USA'
GROUP BY target_country;

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
/* Answer: Drama, Fantasy, Thriller, Comedy, Horror, Family, Romance, Adventure
Action, Sci-Fi, Crime, Mystery, Others */

SELECT DISTINCT genre
FROM genre;

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
-- Answer: Drama 4285

WITH genre_ranking AS (
SELECT genre.genre AS Genre,
		COUNT(movie.title) AS Number_of_movies_per_genre,
        ROW_NUMBER() OVER (ORDER BY COUNT(movie.title) DESC) AS genre_rank
FROM movie
INNER JOIN genre
ON movie.id = genre.movie_id
GROUP BY genre.genre)
SELECT Genre, 
	Number_of_movies_per_genre
FROM genre_ranking
WHERE genre_rank =1;

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
-- Answer: 3,245

WITH single_genre AS (
SELECT title,
		COUNT(genre) AS number_of_genre
FROM movie
INNER JOIN genre
ON movie.id = genre.movie_id
GROUP BY title
HAVING number_of_genre =1)
SELECT COUNT(*) AS number_of_single_genre_movies
FROM single_genre;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
/* Answer: Action 112.88, Romance 109.53, Crime	107.05, Drama 106.77, Fantasy 105.14,
Comedy	102.62, Adventure 101.87, Mystery 101.80, Thriller 101.58, Family 100.97,
Others	100.16, Sci-Fi	97.94, Horror	92.72 */

SELECT genre.genre,
		ROUND(AVG(movie.duration),2) AS avg_duration
FROM movie
INNER JOIN genre
ON movie.id = genre.movie_id
GROUP BY genre
ORDER BY avg_duration DESC;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- Answer: 3
SELECT genre.genre,
		COUNT(movie.title) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY COUNT(movie.title) DESC) AS genre_rank
FROM movie
INNER JOIN genre
ON movie.id = genre.movie_id
GROUP BY genre
ORDER BY genre_rank;

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:
-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
/* Answer:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|max_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		1		|			10		|	       100		  |	   725138	    	 |		1	       |	10		     |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+ */

SELECT MIN(avg_rating) OVER() AS min_avg_rating,
		MAX(avg_rating) OVER() AS max_avg_rating,
        MIN(total_votes) OVER() AS min_total_votes,
        MAX(total_votes) OVER() AS max_total_votes,
        MIN(median_rating) OVER() AS min_median_rating,
        MAX(median_rating) OVER() AS max_median_rating
FROM ratings
LIMIT 1;
  
/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH mov_rank AS (
SELECT movie.title,
		ratings.avg_rating,
        RANK() OVER(ORDER BY ratings.avg_rating DESC) AS movie_rank
FROM ratings
INNER JOIN movie
ON movie.id = ratings.movie_id)
SELECT * 
FROM mov_rank
WHERE movie_rank <= 10;

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
-- Answer median_rating 7 has highest movie_count 2257

SELECT median_rating,
		COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY movie_count DESC;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
-- Answer: Dream Warrior Pictures, National Theatre Live

WITH hit_production AS (
SELECT m.production_company,
		COUNT(m.title) AS movie_count,
        RANK() OVER(ORDER BY COUNT(m.title) DESC) AS prod_company_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
WHERE r.avg_rating >8 AND m.production_company IS NOT NULL
GROUP BY m.production_company)
SELECT * 
FROM hit_production
WHERE prod_company_rank =1;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH more_1000_votes_march2017_usa AS (
SELECT r.movie_id
FROM ratings AS r
	INNER JOIN movie AS m
	ON r.movie_id = m.id
WHERE r.total_votes >1000 
	AND MONTH(m.date_published) = 3
	AND YEAR(m.date_published) = 2017
	AND m.country LIKE '%USA%')
SELECT genre.genre,
		COUNT(filtered_movie.movie_id) AS movie_count
FROM genre
	INNER JOIN more_1000_votes_march2017_usa as filtered_movie
	ON genre.movie_id = filtered_movie.movie_id
GROUP BY genre.genre
ORDER BY movie_count DESC;

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT movie.title,
		ratings.avg_rating,
        genre.genre
FROM movie
	INNER JOIN ratings
    ON movie.id = ratings.movie_id
    INNER JOIN genre
    ON ratings.movie_id = genre.movie_id
WHERE movie.title REGEXP '^(The)'
	  AND ratings.avg_rating > 8
ORDER BY genre.genre;
        
-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
-- Answer 361

WITH filtered_movie_date AS (
SELECT movie.title AS number_of_movie1819_rating8,
movie.date_published,
ratings.median_rating
FROM movie
INNER JOIN ratings
ON movie.id = ratings.movie_id
WHERE (DATE_FORMAT(movie.date_published,'%Y-%m-%d') BETWEEN '2018-04-01' AND '2019-04-01')
AND ratings.median_rating = 8)
SELECT COUNT(*) AS total_movie_rating8_20182019
FROM filtered_movie_date;

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
-- Answer: yes

SELECT movie.country,
	   SUM(ratings.total_votes) AS total_votes_per_country
FROM movie
	 INNER JOIN ratings
	 ON movie.id = ratings.movie_id
WHERE movie.country ='Germany'
	  OR movie.country = 'Italy'
GROUP BY movie.country
ORDER BY total_votes_per_country DESC;

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT
   COUNT(
   CASE
      WHEN
         name IS NULL 
      THEN
         id 
   END
) AS name_nulls, COUNT(
   CASE
      WHEN
         height IS NULL 
      THEN
         id 
   END
) AS height_nulls, COUNT(
   CASE
      WHEN
         date_of_birth IS NULL 
      THEN
         id 
   END
) AS date_of_birth_nulls, COUNT(
   CASE
      WHEN
         known_for_movies IS NULL 
      THEN
         id 
   END
) AS known_for_movies_nulls 
FROM
   names;
   
/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH top_rated_genres AS 
(
   SELECT
      genre,
      COUNT(m.id) AS movie_count,
      RANK () OVER (
   ORDER BY
      COUNT(m.id) DESC) AS genre_rank 
   FROM
      genre AS g 
      LEFT JOIN
         movie AS m 
         ON g.movie_id = m.id 
      INNER JOIN
         ratings AS r 
         ON m.id = r.movie_id 
   WHERE
      avg_rating > 8 
   GROUP BY
      genre 
)
SELECT
   n.name as director_name,
   COUNT(m.id) AS movie_count 
FROM
   names AS n 
   INNER JOIN
      director_mapping AS d 
      ON n.id = d.name_id 
   INNER JOIN
      movie AS m 
      ON d.movie_id = m.id 
   INNER JOIN
      ratings AS r 
      ON m.id = r.movie_id 
   INNER JOIN
      genre AS g 
      ON g.movie_id = m.id 
WHERE
   g.genre IN 
   (
      SELECT DISTINCT
         genre 
      FROM
         top_rated_genres 
      WHERE
         genre_rank <= 3
   )
   AND avg_rating > 8 
GROUP BY
   name 
ORDER BY
   movie_count DESC 
LIMIT 3;


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT
	name as actor_name,
    count(rm.movie_id) as movie_count
FROM
	names n
	INNER JOIN
		role_mapping rm
		ON rm.name_id=n.id
	INNER JOIN
		ratings r
		ON	 rm.movie_id=r.movie_id
WHERE
	median_rating>=8
	AND rm.category='actor'
GROUP BY
	actor_name
ORDER BY
	movie_count DESC
LIMIT 2;

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT
	production_company,
    sum(total_votes) as vote_count,
    rank() over (order by sum(total_votes) desc) as prod_comp_rank
FROM
	movie m
INNER JOIN
	ratings r
	ON m.id = r.movie_id
GROUP BY
	production_company
LIMIT 3;


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH Indian_Movie AS 
(
   SELECT
      n.name AS actor_name,
      r.total_votes,
      m.id,
      r.avg_rating,
      total_votes * avg_rating AS w_avg 
   FROM
      names n 
      INNER JOIN
         role_mapping ro 
         ON n.id = ro.name_id 
      INNER JOIN
         ratings r 
         ON ro.movie_id = r.movie_id 
      INNER JOIN
         movie m 
         ON m.id = r.movie_id 
   WHERE
      category = 'Actor' 
      AND country = 'India' 
   ORDER BY
      actor_name
)
,
Actor AS
(
   SELECT
      *,
      SUM(w_avg) OVER w1 AS rating,
      SUM(total_votes) OVER w2 AS Votes 
   FROM
      Indian_Movie WINDOW w1 AS 
      (
         PARTITION BY actor_name
      )
,
      w2 AS 
      (
         PARTITION BY actor_name
      )
)
SELECT
   actor_name,
   Votes AS total_votes,
   COUNT(id) AS movie_count,
   ROUND(rating / Votes, 2) AS actor_avg_rating,
   DENSE_RANK () OVER (
ORDER BY
   rating / Votes DESC) AS actor_rank 
FROM
   Actor 
GROUP BY
   actor_name 
HAVING
   movie_count >= 5;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
            
WITH Indian AS 
(
   SELECT
      n.name AS actress_name,
      r.total_votes,
      m.id,
      r.avg_rating,
      total_votes * avg_rating AS w_avg 
   FROM
      names n 
      INNER JOIN
         role_mapping ro 
         ON n.id = ro.name_id 
      INNER JOIN
         ratings r 
         ON ro.movie_id = r.movie_id 
      INNER JOIN
         movie m 
         ON m.id = r.movie_id 
   WHERE
      category = 'Actress' 
      AND languages = 'Hindi' 
   ORDER BY
      actress_name
)
,
Actress AS
(
   SELECT
      *,
      SUM(w_avg) OVER w1 AS rating,
      SUM(total_votes) OVER w2 AS Votes 
   FROM
      Indian WINDOW w1 AS 
      (
         PARTITION BY actress_name
      )
,
      w2 AS 
      (
         PARTITION BY actress_name
      )
)
SELECT
   actress_name,
   Votes AS total_votes,
   COUNT(id) AS movie_count,
   ROUND(rating / Votes, 2) AS actress_avg_rating,
   DENSE_RANK () OVER (
ORDER BY
   rating / Votes DESC) AS actress_rank 
FROM
   Actress 
GROUP BY
   actress_name 
HAVING
   movie_count >= 3;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT
	title, 
	CASE	
		WHEN r.avg_rating>8 THEN 'Superhit movie'
		WHEN r.avg_rating >=7 AND r.avg_rating<=8 THEN 'Hit movies'
		WHEN r.avg_rating >=5 AND r.avg_rating<=7 THEN 'One-time watch movies'
		ELSE 'Flop movies'
		END AS category
FROM
	movie m
	INNER JOIN
		ratings r
		ON m.id=r.movie_id
	INNER JOIN
		genre g
		ON m.id=g.movie_id
WHERE
	g.genre = 'thriller'
ORDER BY r.avg_rating DESC;

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
WITH genre_summary AS 
(
   SELECT
      genre,
      ROUND(AVG(duration), 2) AS avg_duration 
   FROM
      genre AS g 
      LEFT JOIN
         movie AS m 
         ON g.movie_id = m.id 
   GROUP BY
      genre 
)
SELECT
   *,
   SUM(avg_duration) OVER (
ORDER BY
   genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
   AVG(avg_duration) OVER (
ORDER BY
   genre ROWS UNBOUNDED PRECEDING) AS moving_avg_duration 
FROM
   genre_summary;

-- Round is good to have and not a must have; Same thing applies to sorting

-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
-- Answer: Drama, comedy, thriller
SELECT COUNT(movie_id) AS movie_count,
		genre
FROM genre
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 3;

-- Find the answer from Drama, comedy, thriller genre
WITH movie2 AS (
SELECT *,
		CASE 
		WHEN POSITION('INR' IN worlwide_gross_income)>0 THEN CAST(SUBSTRING(worlwide_gross_income,5) AS FLOAT) *0.013 
        WHEN POSITION('$' IN worlwide_gross_income)>0 THEN CAST(SUBSTRING(worlwide_gross_income,3) AS FLOAT)
        ELSE CAST(worlwide_gross_income AS FLOAT)
		END AS income_usd
FROM movie),
top_movies AS (
SELECT genre.genre,
		movie2.year,
        movie2.title AS movie_name,
        movie2.worlwide_gross_income AS worldwide_gross_income,
        ROW_NUMBER() OVER(PARTITION BY movie2.year ORDER BY movie2.income_usd DESC) AS movie_rank
FROM movie2
	 INNER JOIN genre
     ON movie2.id = genre.movie_id
WHERE genre.genre in ('Drama','Comedy','Thriller')
)
SELECT * 
FROM top_movies
WHERE movie_rank<=5
ORDER BY year, movie_rank;


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
WITH top_production AS (
SELECT movie.production_company,
		COUNT(movie.id) AS movie_count
FROM movie
	INNER JOIN ratings
	ON movie.id = ratings.movie_id
WHERE POSITION(',' IN movie.languages)>0 
		AND ratings.median_rating >=8
        AND movie.production_company IS NOT NULL
GROUP BY movie.production_company)
SELECT *,
	RANK() OVER(ORDER BY movie_count DESC) AS prod_comp_rank
FROM top_production
LIMIT 2;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
with agg as (
  select n.name AS actress_name
         , sum(r.total_votes) as total_votes
         , count(r.movie_id)  as movie_count
         , avg(r.avg_rating)  as actress_avg_rating
         , Row_number() over(
                       order by COUNT(r.movie_id) desc) as actress_rank
  FROM names as n
  INNER JOIN role_mapping as rm
      ON n.id = rm.name_id
  INNER JOIN movie as m
      ON rm.movie_id = m.id
      AND rm.category ='actress'
  INNER JOIN ratings as r
      ON m.id = r.movie_id
      AND r.avg_rating > 8 
  INNER JOIN genre as g
      ON g.movie_id = r.movie_id
      AND g.genre = 'Drama' 
  GROUP BY n.name
  order by movie_count desc
)
SELECT *
FROM agg
WHERE actress_rank <= 3;

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
WITH director_summary AS (
SELECT director_mapping.name_id AS director_id,
		names.name AS director_name,
        COUNT(movie.id) AS number_of_movies,
        AVG(movie.duration) AS avg_inter_movie_days,
		AVG(ratings.avg_rating) AS avg_rating,
        SUM(ratings.total_votes) AS total_votes,
        MIN(ratings.avg_rating) AS min_rating,
        MAX(ratings.avg_rating) AS max_rating,
        SUM(movie.duration) AS total_duration,
        movie.date_published,
        LEAD(movie.date_published,1) OVER(ORDER BY movie.date_published, movie.id) AS next_date_published
FROM names
		INNER JOIN director_mapping
        ON names.id = director_mapping.name_id 
        INNER JOIN movie
        ON director_mapping.movie_id = movie.id
        INNER JOIN ratings
        ON movie.id = ratings.movie_id
GROUP BY names.name)
SELECT director_id,
		director_name,
        number_of_movies,
        AVG(DATEDIFF(next_date_published,date_published)) AS avg_inter_movie_days,
        avg_rating,
        total_votes,
        min_rating,
        max_rating,
        total_duration
FROM director_summary
GROUP BY director_name
ORDER BY number_of_movies DESC
LIMIT 9;

