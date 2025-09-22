-- MUSICSTORE DATA ANALYSIS

-- CREATING TABLES AND IMPORTING DATASETS

--1. ARTIST
CREATE TABLE artist(
artist_id SERIAL PRIMARY KEY,
name VARCHAR(200) NOT NULL
);

--2. ALBUM
CREATE TABLE album(
album_id SERIAL PRIMARY KEY,
title VARCHAR(200) NOT NULL,
artist_id INT NOT NULL,
CONSTRAINT fk_album_artist FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

--3. GENRE
CREATE TABLE genre(
genre_id SERIAL PRIMARY KEY,
name VARCHAR(100)
);

--4. MEDIA_TYPE
CREATE TABLE media_type(
media_type_id SERIAL PRIMARY KEY,
name TEXT
);

--5. TRACK
CREATE TABLE track(
track_id serial primary key,
name varchar(500) ,
album_id integer,
media_type_id integer,
genre_id integer,
composer varchar(250),
milliseconds integer,
bytes integer,
unit_price numeric(10,2),
CONSTRAINT fk_track_album FOREIGN KEY (album_id) REFERENCES album(album_id),
CONSTRAINT fk_track_mediatype FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
CONSTRAINT fk_track_genre FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
) ;

--6. CUSTOMER
CREATE TABLE customer(
customer_id SERIAL PRIMARY KEY,
first_name VARCHAR(100),
last_name VARCHAR(100),
company VARCHAR(200),
address VARCHAR(250),
city VARCHAR(100),
state VARCHAR(100),
country VARCHAR(100),
postal_code VARCHAR(30),
phone VARCHAR(30),
fax VARCHAR(30),
email VARCHAR(200),
support_rep_id INT
);

--7. EMPLOYEE
CREATE TABLE employee (
employee_id SERIAL PRIMARY KEY,
last_name VARCHAR(100),
first_name	VARCHAR(100),
title VARCHAR(100),
reports_to INTEGER,
levels VARCHAR(25),
birthdate VARCHAR(100),
hire_date VARCHAR(100),
address  VARCHAR(500),
city VARCHAR(100),
state TEXT,
country TEXT,
postal_code VARCHAR(100),
phone VARCHAR(30),	
fax	VARCHAR(30),
email VARCHAR(500)  
);

--8. INVOICE
CREATE TABLE invoice(
invoice_id serial primary key,
customer_id int NOT NULL,
invoice_date varchar(100),
billing_address varchar(250),
billing_city varchar(100),
billing_state varchar(100),
billing_country varchar(50),
billing_postal_code varchar(100),
total NUMERIC(10,2),
CONSTRAINT fk_invoice_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

--9. INVOICE_LINE
CREATE TABLE invoice_line(
invoice_line_id SERIAL PRIMARY KEY,
invoice_id INT NOT NULL,
track_id INT NOT NULL,
unit_price NUMERIC(10,2),
quantity INT,
CONSTRAINT fk_invoiceline_invoice FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
CONSTRAINT fk_invoiceline_track FOREIGN KEY (track_id) REFERENCES track(track_id)
);

--10. PLAYLIST
CREATE TABLE playlist(
playlist_id SERIAL PRIMARY KEY,
name VARCHAR(200)
);

--11. PLAYLIST_TRACK
CREATE TABLE playlist_track(
playlist_id int,
track_id int,
CONSTRAINT fk_playlisttrack_playlist FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id),
CONSTRAINT fk_playlisttrack_track FOREIGN KEY (track_id) REFERENCES track(track_id)
);

-- Data Analysis & Business key problems & answers

-- EASY LEVEL:

--Q1. Find the most senior employee based on job title.
--Q2. Determine which countries have the most invoices.
--Q3. Identify the top 3 invoice totals.
--Q4. Find the city with the highest total invoice amount to determine the best location for a promotional event.
--Q5. Identify the customer who has spent the most money.

--MODERATE LEVEL:

--Q6. Find the email, first name, and last name of customers who listen to Rock music
--Q7. Identify the top 10 rock artists based on track count.
--Q8. Find all track names that are longer than the average track length.

--ADVANCED LEVEL:

--Q9. Calculate how much each customer has spent on each artist
--Q10. Determine the most popular music genre for each country based on purchases.
--Q11.  Identify the top-spending customer for each country.

--SOLVING THE QUERIES

--Q1. Find the most senior employee based on job title.

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

--Q2. Determine which countries have the most invoices.

SELECT billing_country, COUNT(*) AS no_of_invoices
FROM invoice
GROUP BY billing_country
ORDER BY no_of_invoices DESC;

--Q3.  Identify the top 3 invoice totals

SELECT * FROM genre
ORDER BY total DESC
LIMIT 3;

--Q4. Find the city with the highest total invoice amount to determine the best location for a promotional event.

SELECT billing_city, ROUND(SUM(total),0) AS total_invoices FROM invoice
GROUP BY billing_city
ORDER BY total_invoices DESC
LIMIT 1;

--Q5. Identify the customer who has spent the most money

SELECT customer.customer_id, first_name, last_name, SUM(total) AS money_spent FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY money_spent DESC
LIMIT 1;

--Q6. Find the email, first name, and last name of customers who listen to Rock music

SELECT DISTINCT first_name, last_name, email FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'

--Q7. Identify the top 10 rock artists based on track count.


SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) as total_songs FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.artist_id
ORDER BY total_songs DESC
LIMIT 10;

--Q8. : Find all track names that are longer than the average track length.

SELECT name, milliseconds FROM track
WHERE milliseconds > (
SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

--Q9. Calculate how much each customer has spent on each artist

WITH best_selling AS (SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM invoice_line
JOIN track ON invoice_line.track_id = track.track_id
JOIN album ON track.album_id = album.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bs.artist_name,
SUM(il.unit_price*il.quantity) AS total_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling bs ON bs.artist_id = alb.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;

--Q10. Determine the most popular music genre for each country based on purchases.

WITH popular_genre AS (SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS row_no 
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY 2, 3, 4
ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE row_no = 1

--Q11.  Identify the top-spending customer for each country.

WITH customer_with_each_country AS (
SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS row_no
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
GROUP BY 1, 2, 3, 4
ORDER BY 4 ASC, 5 DESC
)
SELECT first_name, last_name, billing_country AS country, total_spending 
FROM customer_with_each_country 
WHERE row_no = 1;

