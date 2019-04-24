use sakila;
/*---------------------------------------------------------------------------
1a. Display the first and last names of all actors from the table actor.
---------------------------------------------------------------------------*/
SELECT first_name, last_name 
	FROM actor;
/*---------------------------------------------------------------------------
1b. Display the first and last name of each actor in a single column in upper 
case letters. Name the column Actor Name.
---------------------------------------------------------------------------*/
SELECT UPPER(CONCAT(first_name, ' ', last_name ) )as 'Actor Name'
	FROM actor;  
/*---------------------------------------------------------------------------
2a. You need to find the ID number, first name, and last name of an actor,
 of whom you know only the first name, "Joe." What is one query would you 
 use to obtain this information?
 ---------------------------------------------------------------------------*/
SELECT 
	actor_id as 'ID number'
    ,first_name
    ,last_name 
FROM actor
    where first_name = 'Joe';
/*---------------------------------------------------------------------------
2b. Find all actors whose last name contain the letters GEN:
---------------------------------------------------------------------------*/ 
SELECT 
	*
FROM actor
    where last_name like '%GEN%';
/*---------------------------------------------------------------------------
2c. Find all actors whose last names contain the letters LI. This time, order 
the rows by last name and first name, in that order:
---------------------------------------------------------------------------*/ 
SELECT 
	*
FROM actor
WHERE last_name like '%LI%'
ORDER BY last_name,first_name;
/*---------------------------------------------------------------------------
2d. Using IN, display the country_id and country columns of the following 
countries: Afghanistan, Bangladesh, and China:
---------------------------------------------------------------------------*/ 
SELECT
	country_id
    ,country
FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

/*---------------------------------------------------------------------------
3a. Add a new column : decription to the actor table with data type BLOB 
-- BLOB can be used to store binary data like an image, audio and other 
--multimedia data.
-- and VARCHAR is used to store text of any size up to the limit.
---------------------------------------------------------------------------*/ 
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

/*---------------------------------------------------------------------------
3d. Delete the description column from actor table
---------------------------------------------------------------------------*/ 
ALTER TABLE actor
DROP COLUMN description;
/*---------------------------------------------------------------------------
4a. List the last names of actors, and how many actors have that last name.
---------------------------------------------------------------------------*/ 
SELECT
	last_name,
    COUNT(*) as similar_lastname_count
FROM actor
GROUP BY last_name;
/*---------------------------------------------------------------------------
4b. List last names of actors and the number of actors who have that last name,
 but only for names that are shared by at least two actors
---------------------------------------------------------------------------*/ 
SELECT
	last_name,
    COUNT(*) as similar_lastname_count
FROM actor
GROUP BY last_name
having COUNT(*) > 1 ;
/*---------------------------------------------------------------------------
4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as 
GROUCHO WILLIAMS. Write a query to fix the record.
---------------------------------------------------------------------------*/
-- UPDATE actor
-- SET first_name = 'HARPO'
-- -- SELECT * from actor
-- WHERE first_name = 'GROUCHO' 
-- AND last_name = 'WILLIAMS';
-- /*---------------------------------------------------------------------------
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
-- ---------------------------------------------------------------------------*/
-- UPDATE actor
-- SET first_name = 'GROUCHO'
-- WHERE first_name = 'HARPO' ;
/*---------------------------------------------------------------------------
5a. locate the schema of the address table using show function
---------------------------------------------------------------------------*/
SHOW CREATE TABLE address;
/*---------------------------------------------------------------------------
6a. Use JOIN to display the first and last names, as well as the address, 
of each staff member. Use the tables staff and address:
---------------------------------------------------------------------------*/
SELECT
	first_name
    ,last_name
    ,address
FROM staff s
	JOIN address a
    on s.address_id = a.address_id;
    
/*---------------------------------------------------------------------------
6b. Use JOIN to display the total amount rung up by each staff 
member in August of 2005. Use tables staff and payment.
---------------------------------------------------------------------------*/
SELECT
	SUM(amount) as 'total amount'
FROM staff s
	JOIN payment p
    on p.staff_id = s.staff_id
WHERE MONTH(payment_date) = 8 and YEAR(payment_date) = '2005'
GROUP BY MONTH(payment_date)
;
/*---------------------------------------------------------------------------
6c.List each film and the number of actors who are listed for that film. 
Use tables film_actor and film. Use inner join.
---------------------------------------------------------------------------*/
SELECT
	title
	,COUNT(actor_id) as ' Number of actors'
FROM film f
  JOIN film_actor fa 
  ON fa.film_id = f.film_id
GROUP BY title;
/*---------------------------------------------------------------------------
6d.How many copies of the film Hunchback Impossible exist in the inventory system?
---------------------------------------------------------------------------*/
Select title , (
		Select count(*) from inventory i
        where film.film_id = i.film_id) as no_of_copies
from film
where title = 'Hunchback Impossible';
/*---------------------------------------------------------------------------
6e. Using the tables payment and customer and the JOIN command, list the total
 paid by each customer. List the customers alphabetically by last name:
---------------------------------------------------------------------------*/
SELECT 
	first_name
    ,last_name
	,SUM(amount) as 'total paid'
FROM customer c
JOIN payment p
  ON c.customer_id = p.customer_id
GROUP BY first_name
    ,last_name
ORDER BY last_name;
/*---------------------------------------------------------------------------
7a.Use subqueries to display the titles of movies starting with the letters 
K and Q whose language is English.
---------------------------------------------------------------------------*/
SELECT title 
FROM film
WHERE (title like 'K%' or title like 'Q%')
and language_id in (Select language_id from language where name = 'English');
/*---------------------------------------------------------------------------
7b. Use subqueries to display all actors who appear in the film Alone Trip.
---------------------------------------------------------------------------*/
SELECT actor_id, first_name, last_name 
FROM actor a
WHERE actor_id in (select actor_id from film_actor
						where film_id in (
										Select film_id from film 
											where title = 'Alone Trip'));
/*---------------------------------------------------------------------------
7c. You want to run an email marketing campaign in Canada, for which 
you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.
---------------------------------------------------------------------------*/
SELECT
	CONCAT(first_name, ' ' , last_name) as Name,
    email
FROM customer cu
JOIN address a on a.address_id = cu.address_id
JOIN city on city.city_id = a.city_id
JOIN country co
    ON co.country_id =  city.country_id
WHERE country = 'Canada';
/*---------------------------------------------------------------------------
7d.Identify all movies categorized as family films.
---------------------------------------------------------------------------*/
SELECT f.* from category cat
JOIN film_category fc 
	ON fc.category_id = cat.category_id
JOIN film f 
	ON f.film_id = fc.film_id
WHERE cat.name = 'Family';

/*---------------------------------------------------------------------------
7e. Display the most frequently rented movies in descending order.
---------------------------------------------------------------------------*/
SELECT
     title,COUNT(i.film_id) as total_rentals
FROM rental r
JOIN inventory i
	ON i.inventory_id = r.inventory_id
JOIN film f 
	ON i.film_id = f.film_id
GROUP BY title, f.film_id
ORDER BY COUNT(i.film_id) DESC;
/*---------------------------------------------------------------------------
7f. Write a query to display how much business, in dollars, each store 
brought in.
---------------------------------------------------------------------------*/
SELECT 
	store_id,
    country,
    total_in_local_curr,
    concat('$', total_in_USD) as total_in_USD
FROM
(SELECT s.store_id,
co.country,sum(amount)as total_in_local_curr,
Round(SUM(CASE WHEN co.country = 'Australia' THEN amount*0.71
WHEN co.country = 'Canada' THEN amount*0.75 END),2) as total_in_USD
FROM store s
JOIN staff sf on sf.store_id = s.store_id 
JOIN address a on a.address_id = s.address_id
JOIN payment p on p.staff_id = sf.staff_id
JOIN city on city.city_id = a.city_id
JOIN country co
    ON co.country_id =  city.country_id
group by s.store_id,co.country)subq
;
/*---------------------------------------------------------------------------
7g. Write a query to display for each store its store ID, city, and country.
---------------------------------------------------------------------------*/
SELECT s.store_id,
city, country
FROM store s
JOIN address a on a.address_id = s.address_id
JOIN city on city.city_id = a.city_id
JOIN country co
    ON co.country_id =  city.country_id;
/*---------------------------------------------------------------------------
7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables:
 category, film_category, inventory, payment, and rental.)
---------------------------------------------------------------------------*/
SELECT
	cat.name, SUM(amount) as gross_revenue
FROM film_category fc
JOIN category cat 
	ON cat.category_id = fc.category_id
JOIN inventory  i
	ON i.film_id = fc.film_id
JOIN rental r
	ON r.inventory_id = i.inventory_id
LEFT JOIN payment p
	ON p.rental_id = r.rental_id
  group by cat.name
  ORDER BY SUM(amount) desc
  LIMIT 5
 ;
/*---------------------------------------------------------------------------
8a. In your new role as an executive, you would like to have an easy way of 
viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 
7h, you can substitute another query to create a view.
---------------------------------------------------------------------------*/
CREATE VIEW top5genres
AS
SELECT
	cat.name, SUM(amount) as gross_revenue
FROM film_category fc
JOIN category cat 
	ON cat.category_id = fc.category_id
JOIN inventory  i
	ON i.film_id = fc.film_id
JOIN rental r
	ON r.inventory_id = i.inventory_id
LEFT JOIN payment p
	ON p.rental_id = r.rental_id
  group by cat.name
  ORDER BY SUM(amount) desc
  LIMIT 5;
/*---------------------------------------------------------------------------
8b. How would you display the view that you created in 8a?
---------------------------------------------------------------------------*/
Select * from top5genres;
/*---------------------------------------------------------------------------
8c. You find that you no longer need the view top_five_genres. 
Write a query to delete it.
---------------------------------------------------------------------------*/
Drop view top5genres;


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
	
	




	