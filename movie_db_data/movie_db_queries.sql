/*
	1. Print profit in million
*/
SELECT movie_id, budget, revenue, unit,
	CASE
		WHEN unit = 'Billions' THEN (revenue - budget)*1000 
		WHEN unit = 'Thousands' THEN (revenue - budget)/1000 
        ELSE (revenue - budget)
	END AS profit_in_mln
FROM financials;


SELECT COUNT(DISTINCT industry) 
FROM movies;

/*
	1. Print all movie titles and release year for all Marvel Studios movies.
*/
SELECT title, release_year
FROM movies
WHERE studio LIKE "%Marvel%";

/*
	2. Print all movies that have Avenger in their name.
*/
SELECT title
FROM movies
WHERE title LIKE "%Avenger%";

/*
	3. Print the year when the movie "The Godfather" was released.
*/
SELECT release_year
FROM movies
WHERE title LIKE "%The Godfather%";

/*
	4. Print all distinct movie studios in the Bollywood industry.
*/
SELECT DISTINCT studio
FROM movies
WHERE industry LIKE "%Bollywood%";
/*
	1. Print all movies in the order of their release year (latest first)
*/
SELECT * 
FROM movies
ORDER BY release_year DESC;

/*
	2. All movies released in the year 2022
*/
SELECT *
FROM movies
WHERE release_year = 2022;

/*
	3. Now all the movies released after 2020
*/
SELECT *
FROM movies
WHERE release_year > 2020;
/*	
	4. All movies after the year 2020 that have more than 8 rating
*/
SELECT *
FROM movies
WHERE release_year > 2020 AND imdb_rating > 8;

/*
	5. Select all movies that are by Marvel studios and Hombale Films
*/
SELECT * 
FROM movies
WHERE studio IN ("Marvel studios", "Hombale Films");
/*
	6. Select all THOR movies by their release year
*/
SELECT *
FROM movies
WHERE title LIKE "%Thor%"
ORDER BY release_year;

/*
	7. Select all movies that are not from Marvel Studios
*/
SELECT *
FROM movies
WHERE studio NOT IN ("Marvel studios");

/*
	1. Print profit % for all the movies
*/
SELECT * FROM moviesdb.financials;

SELECT movie_id, (100 * (revenue - budget)/revenue) AS profit_in_percentage
FROM financials;

/*
	1. How many movies were released between 2015 and 2022
*/
SELECT COUNT(*) AS no_of_movies
FROM movies
WHERE release_year BETWEEN 2015 AND 2022
ORDER BY release_year;

SELECT release_year, 
		COUNT(*) AS no_of_movies
FROM movies
WHERE release_year BETWEEN 2015 AND 2022
GROUP BY release_year
ORDER BY release_year;

/*
	2. Print the max and min movie release year
*/
SELECT studio,
		MIN(release_year) AS min_year,
		MAX(release_year) AS max_year
FROM movies
GROUP BY (studio);
	
/*
	3. Print a year and how many movies were released in that year starting with the latest year
*/

SELECT release_year, 
		COUNT(*) AS no_of_movies
FROM movies
GROUP BY release_year
ORDER BY release_year DESC;


/*
	4. Print all the years where more than 2 movies were released
*/
SELECT release_year, 
		COUNT(*) AS no_of_movies
FROM movies
GROUP BY release_year
HAVING no_of_movies > 2
ORDER BY release_year DESC;

/*
	1. Show all the movies with their language names
*/
SELECT M.movie_id, M.title, 
		M.industry, M.release_year, 
		M.imdb_rating, M.studio, 
        L.language_id, L.name
FROM movies M
JOIN languages L
USING (language_id);  
  
  
/*
	2. Show all Telugu movie names (assuming you don't know the language id for Telugu)
*/
SELECT M.movie_id, M.title, 
		M.industry, M.release_year, 
		M.imdb_rating, M.studio, 
        L.language_id, L.name
FROM movies M
LEFT JOIN languages L
USING (language_id)
WHERE L.name LIKE "%Telugu%"; 

/*
	3. Show the language and number of movies released in that language
*/

SELECT L.language_id, L.name, COUNT(language_id) AS no_of_movies
FROM movies M
LEFT JOIN languages L
USING (language_id)
GROUP BY name
ORDER BY language_id;

/*
	Generate a report of all Hindi movies sorted by their revenue amount in millions.
	Print movie name, revenue, currency, and unit
*/
SELECT M.title, L.name,
		IF (F.UNIT LIKE "Billions", F.revenue * 1000, F.revenue) AS revenue_in_mil, 
        F.currency
FROM movies M
INNER JOIN financials F
USING (movie_id)
INNER JOIN languages L
WHERE name LIKE "%Hindi%";

/*
	Select all movies whose rating is greater than *ANY* of the Marvel movies rating
*/
SELECT *
FROM movies 
WHERE imdb_rating > ANY (
	SELECT imdb_rating
    FROM movies
    WHERE studio LIKE "%Marvel Studios%");
    
    
SELECT *
FROM movies 
WHERE imdb_rating > ALL (
	SELECT imdb_rating
    FROM movies
    WHERE studio LIKE "%Marvel Studios%");
    
/*
	Select the Actor id, actor name & 
    total number of movies they acted in
*/
SELECT A.actor_id, A.Name, COUNT(*) AS movie_cnt
FROM movie_actor MA
JOIN actors A
USING (actor_id)
GROUP BY actor_id;

SELECT actor_id, name,
		(SELECT COUNT(*) 
         FROM movie_actor
         WHERE actor_id = actors.actor_id) AS movie_cnt
FROM actors
ORDER BY movie_cnt DESC;

/*
	Get all actors whose age
    is between 70 & 85
*/
SELECT actor_name, age
FROM (SELECT name AS actor_name,
	  YEAR(CURDATE()) - birth_year AS age
      FROM actors) AS actors_age
WHERE age > 70 AND age < 85;

WITH actors_age AS (
	SELECT name AS actor_name,
	  YEAR(CURDATE()) - birth_year AS age
      FROM actors)
SELECT *
FROM actors_age
WHERE age > 70 AND AGE < 85;

/*
	Movies that produced 500% profit &
    their rating was less than avg rating
    for all movies
*/
WITH 
	x AS (SELECT *, (100 * (revenue - budget)/budget) AS profit    
		  FROM financials),
	y AS (SELECT * 
		  FROM movies
		  WHERE imdb_rating < (SELECT AVG(imdb_rating) FROM movies))

SELECT x.movie_id, x.profit,
	   y.title, y.imdb_rating
FROM x
JOIN y
USING (movie_id)
WHERE profit >= 500
    
/*
	
*/
    

    

