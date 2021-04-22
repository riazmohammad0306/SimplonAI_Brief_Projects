USE sakila; 

-- INTERROGATIONS AVANCÉES --
-- Question 1 --
SELECT monthname(rental_date)
FROM rental
WHERE rental_date LIKE '2006%';

-- Question 2 --
SELECT rental_duration
FROM film;

-- Question 3 --
-- Je considère que pour un jour donnée pour emprunter un livre avant 1h00 du matin il faut le louer entre 00h00 et 00h59 ---
SELECT DATE_FORMAT(rental_date, 'Le %D %M %Y à %H heures %i minutes et %s secondes' )
FROM rental
WHERE DATE(rental_date) LIKE '2005%' AND
TIME(rental_date) BETWEEN '00:00:00' AND '00:59:59';

-- Question 4 -- 
-- Les locations commencent le 24/05/2005 ... --
SELECT rental_date
FROM rental
WHERE MONTH(rental_date) BETWEEN 4 AND 5;

-- Question 5 --
SELECT title
FROM film
WHERE title NOT LIKE 'LE%';

-- Question 6 -- 
SELECT rating,IF(rating ='NC-17', 'oui', 'non') AS NC17_or_not
FROM film
WHERE rating = 'PG-13' OR rating = 'NC-17';

-- Question 7 -- 
SELECT name
FROM category
where name like 'A%' or name like 'C%'; 

-- Question 7 Option LEFT -- 
SELECT name
FROM category 
WHERE LEFT(name, 1) = 'A' or LEFT(name,1) = 'C';

-- Question 8 -- 
SELECT SUBSTRING(name, 1, 3)
FROM category; 

-- Question 8 Option LEFT -- 
SELECT LEFT(name, 3) 
FROM category; 

-- Question 9 -- 
-- L'énoncé dit : Lister les premiers ... Je limite aux 5 premiers --
SELECT REPLACE(first_name,"E", "A")
FROM actor
LIMIT 5;

-- LES JOINTURES --
-- Question 1 -- 
-- Il n'y a que des films en anglais --
SELECT film.title, language.name
FROM film
JOIN language
ON film.language_id = language.language_id
LIMIT 10; 

-- Question 2 -- 
SELECT film.title
FROM film 
JOIN film_actor 
ON film.film_id = film_actor.film_id
JOIN actor 
ON film_actor.actor_id = actor.actor_id
WHERE actor.first_name = 'JENNIFER' AND actor.last_name ='DAVIS' 
AND film.release_year = '2006';

-- Question 3 -- 
SELECT customer.last_name, customer.first_name
FROM customer
LEFT JOIN rental 
ON customer.customer_id = rental.customer_id
LEFT JOIN inventory 
ON rental.inventory_id = inventory.inventory_id
LEFT JOIN film 
ON inventory.film_id = film.film_id 
WHERE film.title = 'ALABAMA DEVIL'; 

-- Question 4 -- 
-- Donne les films loués dans un vidéo club situé à Woodridge --
SELECT DISTINCT film.title, inventory.film_id
FROM film 
JOIN inventory 
ON film.film_id = inventory.film_id
JOIN store 
ON inventory.store_id = store.store_id 
JOIN address
ON store.address_id = address.address_id
JOIN city 
ON address.city_id = city.city_id
WHERE city.city = 'Woodridge'; 

-- Question 4 -- 
-- Il n'y a pas de clients habitants à Woodridge -- 
SELECT DISTINCT film.title 
FROM film 
JOIN inventory 
ON film.film_id = inventory.film_id
JOIN rental 
ON inventory.inventory_id = rental.inventory_id 
JOIN customer
ON rental.customer_id = customer.customer_id
JOIN address 
ON customer.address_id = address.address_id
JOIN city
ON address.city_id = city.city_id
WHERE city.city = 'Woodridge'; 

-- Question 5 --
-- Obligé de spécifier where rental.return_date is not null car certain films n'ont jamais été rendus --
SELECT TIMEDIFF(rental.return_date, rental.rental_date) as duree_location, film.title
FROM rental
JOIN inventory
ON rental.inventory_id = inventory.inventory_id
JOIN film 
ON film.film_id = inventory.film_id
WHERE rental.return_date IS NOT NULL
ORDER BY duree_location ASC
LIMIT 10;   

-- Question 6 -- 
SELECT film.title, film_category.category_id,category.name
FROM film 
JOIN film_category
ON film.film_id = film_category.film_id 
JOIN category 
ON film_category.category_id = category.category_id
WHERE category.name = 'Action';

-- Question 7 -- 
SELECT TIMEDIFF(rental.return_date, rental.rental_date) AS duree_location, film.title
FROM rental
JOIN inventory
ON rental.inventory_id = inventory.inventory_id
JOIN film 
ON film.film_id = inventory.film_id
WHERE rental.return_date IS NOT NULL AND HOUR(TIMEDIFF(rental.return_date, rental.rental_date)) < 48
ORDER BY duree_location ASC;


-- POUR ALLER PLUS LOIN -- 
-- Question 1 --
SELECT customer.last_name AS nom, customer.first_name AS prenom, film.title, store.store_id, TIMEDIFF(rental.return_date,rental.rental_date) AS duree
FROM film
JOIN inventory 
ON film.film_id = inventory.film_id
JOIN rental 
ON inventory.inventory_id = rental.inventory_id
JOIN customer 
ON rental.customer_id = customer.customer_id 
JOIN store
ON customer.store_id  = store.store_id
WHERE rental.return_date IS NOT NULL 
ORDER BY duree DESC
LIMIT 10;

-- Question 2 -- 
SELECT customer.last_name AS nom, customer.first_name AS prenom, SUM(payment.amount) AS montant_depense 
FROM payment
JOIN customer
ON payment.customer_id = customer.customer_id
GROUP BY payment.customer_id
ORDER BY montant_depense DESC 
LIMIT 10;

-- Question 3 -- 
SELECT film.title, AVG(TIMEDIFF(rental.return_date, rental.rental_date)) AS moyenne
FROM film
JOIN inventory
ON film.film_id = inventory.film_id 
JOIN rental 
ON inventory.inventory_id = rental.inventory_id
WHERE rental.return_date IS NOT NULL
GROUP BY film.title 
ORDER BY moyenne DESC; 

-- Question 4 -- 
SELECT film.title
FROM film
LEFT JOIN inventory 
ON film.film_id = inventory.film_id
WHERE inventory.film_id IS NULL; 

-- Question 5 -- 
SELECT store.store_id, COUNT(staff.staff_id) AS nbr_employes
FROM store
JOIN staff 
ON store.store_id = staff.store_id
GROUP BY store.store_id;

-- Question 6 -- 
SELECT city, COUNT(store.store_id) AS nbr_video_club
FROM store
JOIN address 
ON store.address_id = address.address_id 
JOIN city 
ON address.city_id = city.city_id
GROUP BY city; 

-- Question 7 --
SELECT film.title, film.length AS duree_max
FROM film 
JOIN film_actor 
ON film.film_id = film_actor.film_id
JOIN actor 
ON film_actor.actor_id = actor.actor_id
WHERE actor.first_name = 'Johnny' AND actor.last_name = 'Lollobrigida'
ORDER BY duree_max DESC
LIMIT 1;  

-- Question 8 --
-- EN SECONDES -- 
SELECT AVG(timediff(rental.return_date,rental.rental_date)) AS temps_moyen
FROM rental 
JOIN inventory 
ON rental.inventory_id = inventory.inventory_id 
JOIN film 
ON inventory.film_id = film.film_id 
WHERE film.title = 'Academy dinosaur'; 

-- Question 8 __ 
-- EN JOURS --
SELECT AVG(datediff(rental.return_date,rental.rental_date)) AS temps_moyen
FROM rental 
JOIN inventory 
ON rental.inventory_id = inventory.inventory_id 
JOIN film 
ON inventory.film_id = film.film_id 
WHERE film.title = 'Academy dinosaur'; 

-- Question 9 -- 
SELECT store.store_id, film.title, count(film.title) as nb_film
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN store ON inventory.store_id = store.store_id
GROUP BY inventory.film_id, store.store_id
HAVING nb_film > 2;

-- Question 10 -- 
SELECT film.title 
FROM film 
WHERE film.title LIKE '%din%';

-- Question 11 -- 
SELECT film.title, COUNT(film.title) AS nb_emprunts
FROM film 
JOIN inventory
ON film.film_id = inventory.film_id 
JOIN rental 
ON inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY nb_emprunts DESC
LIMIT 5; 

-- Question 12 -- 
-- Il n'y a que des films sortis en 2006 --
SELECT film.title, film.release_year
FROM film 
WHERE film.release_year = '2003' OR film.release_year = '2005' OR film.release_year = '2006';

-- Question 13 -- 
SELECT rental.rental_date, rental.return_date, film.title
FROM rental
JOIN inventory
ON rental.inventory_id = inventory.inventory_id
JOIN film 
ON inventory.film_id = film.film_id
WHERE rental.return_date IS NULL
ORDER BY rental_date
LIMIT 10;

-- Question 14 --
SELECT film.title, film.length, category.name
FROM film 
JOIN film_category
ON film.film_id = film_category.film_id 
JOIN category 
ON film_category.category_id = category.category_id
WHERE film.length > 120 AND category.name = 'Action';

-- Question 15 -- 
SELECT DISTINCT customer.first_name, customer.last_name
FROM customer 
JOIN rental 
ON customer.customer_id = rental.customer_id 
JOIN inventory 
ON rental.inventory_id = inventory.inventory_id
JOIN film
ON inventory.film_id = film.film_id 
WHERE film.rating = 'NC-17'; 

-- Question 16 -- 
-- Aucune langue originale n'est mentionnée dans la base de donnée --
-- Tous les films sont en anglais, original_language_id = 1 correspond à l'anglais --
SELECT film.title
FROM film
JOIN language
ON film.language_id = language.language_id
JOIN film_category 
ON film.film_id = film_category.film_id
JOIN category 
ON film_category.category_id = category.category_id
WHERE category.name = 'Animation' AND film.original_language_id = 1;

-- Question 17 -- 
-- Afficher les films dans lesquels une actrice nommée Jennifer a joué --
SELECT film.title, actor.first_name, actor.last_name
FROM film 
JOIN film_actor 
ON film.film_id = film_actor.film_id 
JOIN actor 
ON film_actor.actor_id = actor.actor_id
WHERE actor.first_name = 'Jennifer'; 

-- Question 17 Bonus -- 
-- (bonus: en même temps qu'un acteur nommé Johnny) -- 
SELECT film.title
FROM film
JOIN film_actor 
ON film.film_id = film_actor.film_id
JOIN actor 
ON film_actor.actor_id = actor.actor_id
WHERE actor.first_name = 'Jennifer' AND film.film_id IN (
    SELECT film.film_id
    FROM film
    JOIN film_actor 
    ON film.film_id = film_actor.film_id
    JOIN actor 
    ON film_actor.actor_id = actor.actor_id
    WHERE actor.first_name = 'Johnny'
);


-- Question 18 -- 
SELECT COUNT(rental.rental_id) AS counting, category.name
FROM rental 
JOIN inventory 
ON rental.inventory_id = inventory.inventory_id
JOIN film 
ON inventory.film_id = film.film_id 
JOIN film_category
ON film.film_id = film_category.film_id
JOIN category
ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY counting DESC
LIMIT 3; 

-- Question 19 -- 
-- Il n'y a que deux villes de locations ... --
SELECT COUNT(rental.rental_id) AS counting, city.city
FROM rental
JOIN inventory
ON rental.inventory_id = inventory.inventory_id
JOIN store 
ON inventory.store_id = store.store_id 
JOIN address 
ON store.address_id = address.address_id
JOIN city 
ON address.city_id = city.city_id
GROUP BY city.city
ORDER BY counting DESC
LIMIT 10; 

-- Question 20 -- 
-- Tous les acteurs ont au moins joués dans 14 films --
SELECT actor.first_name, actor.last_name, COUNT(film_actor.film_id) AS nb_film_joues
FROM actor 
JOIN film_actor 
ON actor.actor_id = film_actor.actor_id 
GROUP BY actor.actor_id
HAVING nb_film_joues > 1
ORDER BY nb_film_joues;

-- REQUÊTES AGRÉGATION -- 
-- Question 1 -- 
SELECT category.name, COUNT(film_actor.film_id) AS nbr_film_joues
FROM category
JOIN film_category
ON category.category_id = film_category.category_id 
JOIN film 
ON film_category.film_id = film.film_id 
JOIN film_actor 
ON film.film_id = film_actor.film_id 
JOIN actor 
ON film_actor.actor_id = actor.actor_id 
WHERE actor.first_name = 'Johnny' AND actor.last_name = 'LOLLOBRIGIDA'
GROUP BY category.name; 

-- Question 2 -- 
SELECT category.name, COUNT(film_actor.film_id) AS nbr_film_joues
FROM category
JOIN film_category
ON category.category_id = film_category.category_id 
JOIN film 
ON film_category.film_id = film.film_id 
JOIN film_actor 
ON film.film_id = film_actor.film_id 
JOIN actor 
ON film_actor.actor_id = actor.actor_id 
WHERE actor.first_name = 'Johnny' AND actor.last_name = 'LOLLOBRIGIDA'
GROUP BY category.name
HAVING nbr_film_joues > 3;

-- Question 3 -- 
SELECT AVG(timestampdiff(hour, rental.rental_date, rental.return_date)) as duree_moy, actor.first_name, actor.last_name
FROM rental
JOIN inventory
ON rental.inventory_id = inventory.inventory_id 
JOIN film
ON inventory.film_id = film.film_id 
JOIN film_actor 
ON film.film_id = film_actor.film_id
JOIN actor 
ON film_actor.actor_id = actor.actor_id 
GROUP BY actor.actor_id
ORDER BY duree_moy DESC;

-- Question 4 -- 
SELECT SUM(payment.amount) AS depense, customer.first_name, customer.last_name
FROM payment 
JOIN customer
ON payment.customer_id = customer.customer_id 
GROUP BY customer.customer_id 
ORDER BY depense DESC; 
