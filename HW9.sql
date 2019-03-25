USE sakila;
SHOW tables;

SELECT * FROM actor;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT actor.first_name, actor.last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT concat_ws(' ', ucase(actor.first_name), ucase(actor.last_name)) AS 'Actor Name' FROM actor;
SELECT concat(ucase(actor.first_name),' ', ucase(actor.last_name)) AS 'Actor Name' FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information? */
SELECT actor.actor_id, actor.first_name, actor.last_name FROM actor WHERE actor.first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE actor.last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor WHERE actor.last_name LIKE '%LI%' ORDER BY actor.last_name, actor.first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
-- SELECT * FROM country;
SELECT * FROM country WHERE country in ('Afghanistan', 'Bangladesh', 'China');

/* 3a. You want to keep a description of each actor. 
You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB 
(Make sure to research the type BLOB, as the difference between it and VARCHAR are significant). */
SELECT * FROM actor;
ALTER TABLE actor ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
SELECT * FROM actor;
ALTER TABLE actor DROP column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
/* SELECT actor.last_name FROM actor;
SELECT DISTINCT actor.last_name FROM actor;
SELECT actor.last_name, count(actor.last_name) AS Count FROM actor GROUP BY actor.last_name ORDER BY Count DESC; */
SELECT actor.last_name, count(actor.last_name) AS Count FROM actor GROUP BY actor.last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT actor.last_name, count(actor.last_name) AS Count FROM actor GROUP BY actor.last_name HAVING Count >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT * FROM actor WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
UPDATE actor SET first_name = "HARPO" WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
SELECT * FROM actor WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. */
-- SELECT * FROM actor WHERE first_name = "HARPO"; 
UPDATE actor SET first_name = "GROUCHO" WHERE first_name = "HARPO" AND last_name = "WILLIAMS";
SELECT * FROM actor WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
/* SELECT * FROM address;
DESCRIBE address; */
SHOW COLUMNS from sakila.address;
SHOW CREATE TABLE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address FROM staff INNER JOIN address ON address.address_id = staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'Total Amount' FROM staff
INNER JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%' GROUP BY payment.staff_id; 

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS 'Number of Actors' FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, COUNT(inventory.film_id) AS 'Inventory Count' FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE film.title = "Hunchback Impossible"
GROUP BY film.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.last_name, customer.first_name, SUM(payment.amount) AS 'Total Paid per Customer' FROM customer
INNER JOIN payment ON  payment.customer_id = customer.customer_id
GROUP BY payment.customer_id
ORDER BY customer.last_name; # by default it is Ascending ASC|DESC

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. */
SELECT film.title FROM film 
WHERE film.language_id IN (SELECT language.language_id FROM language WHERE language.name = 'english') AND (film.title LIKE 'k%' OR film.title LIKE 'q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor.first_name, actor.last_name FROM actor
WHERE actor.actor_id IN (SELECT film_actor.actor_id FROM film_actor WHERE film_actor.film_id IN (SELECT film.film_id FROM film WHERE film.title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email, co.country FROM customer c
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ci ON ci.city_id = a.city_id
INNER JOIN country co ON co.country_id = ci.country_id
WHERE co.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title FROM film WHERE film_id IN (SELECT film_id FROM film_category WHERE category_id IN (SELECT category_id FROM category WHERE name = "Family"));

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.film_id, f.title, COUNT(r.rental_id) AS "Number of Rentals" FROM inventory i
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT sto.store_id, SUM(p.amount) AS "Total" FROM store sto
INNER JOIN staff sta ON sto.store_id = sta.store_id
INNER JOIN payment p ON p.staff_id = sta.staff_id
GROUP BY sto.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, ci.city, co.country FROM store s
INNER JOIN address a ON s.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON ci.country_id = co.country_id;

/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */
SELECT c.name, SUM(p.amount) as "Gross Amount" FROM category c
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN inventory i ON fc.film_id = i.film_id
INNER JOIN rental r ON r.inventory_id = i.inventory_id
INNER JOIN payment p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC limit 5;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view. */
CREATE VIEW Top_Five_Genres_By_Gross_Revenue AS
SELECT c.name, SUM(p.amount) as "Gross Amount" FROM category c
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN inventory i ON fc.film_id = i.film_id
INNER JOIN rental r ON r.inventory_id = i.inventory_id
INNER JOIN payment p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC limit 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_Five_Genres_By_Gross_Revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_Five_Genres_By_Gross_Revenue;

