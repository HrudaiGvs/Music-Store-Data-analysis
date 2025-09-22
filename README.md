# 🎵 Music Store Data Analysis (SQL Project)
## 📌 Project Overview

This project focuses on analyzing a Music Store dataset using SQL to extract insights related to sales, customers, artists, and revenue.
The goal was to practice SQL querying, joins, subqueries, aggregate functions, and analytical queries while answering real-world business questions.

## 🛠️ Tools & Technologies

PostgreSQL / MySQL / SQLite (whichever you used)
SQL (DDL, DML, Joins, Subqueries, CTEs, Window Functions)
CSV Dataset imported into SQL database

## 📂 Dataset

The dataset contains tables such as:

- Albums – Album information (AlbumId, Title, ArtistId)
- Artists – Artist details
- Customers – Customer information (name, country, email)
- Employees – Employee details (support reps)
- Invoices – Sales transactions
- InvoiceLines – Individual items in each invoice
- Tracks – Songs information (TrackId, AlbumId, GenreId, MediaTypeId)
- Genres – Music genres
- MediaTypes – File formats (MPEG, AAC, etc.)
- Playlists & PlaylistTracks – Playlist details

## 📊 Business Questions Solved

1. Find the most senior employee based on job title.
2. Determine which countries have the most invoices.
3. Identify the top 3 invoice totals
4. Find the city with the highest total invoice amount to determine the best location for a promotional event.
5. Identify the customer who has spent the most money.
6. Find the email, first name, and last name of customers who listen to Rock music
7. Identify the top 10 rock artists based on track count.
8. Find all track names that are longer than the average track length.
9. Calculate how much each customer has spent on each artist
10. Determine the most popular music genre for each country based on purchases.
11. Identify the top-spending customer for each country.

## 📝 Sample SQL Queries

1. **Identify the top 10 rock artists based on track count.**
```sql
SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) as total_songs FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.artist_id
ORDER BY total_songs DESC
LIMIT 10;
```

2. **Calculate how much each customer has spent on each artist**
```sql
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
```
3. **Identify the customer who has spent the most money.**
```sql
SELECT customer.customer_id, first_name, last_name, SUM(total) AS money_spent FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY money_spent DESC
LIMIT 1;
```

## 📈 Insights & Findings

- The city with the highest total invoice amount to determine the best location for a promotional event is **Prague** with **273** total invoices.
- **Rock** and **Alternative** genres dominated sales in each country.
- The Top 10 Rock Artists based on the track count
      - Led Zeppelin
      - U2
      - eep Purple
      - Iron Maiden
      - Pearl Jam
      - Van Halen
      - Queen
      - The Rolling Stones
      - Creedence Clearwater Revival
      - Kiss

- Artist **Led Zeppelin** was the most profitable artist.
- The Top Spending Customer is **František Wichterlová**	from **Czech Republic**.

## 🚀 Key Learnings

- Writing complex joins and subqueries to combine multiple tables.
- Using aggregate functions (SUM, COUNT, AVG, MAX) for business insights.
- Practicing window functions for ranking and running totals.
- Understanding real-world database schema design for a music store.

## 📎 Files in Repository

README.md – Documentation

queries.sql – All SQL queries used

schema.png  – Database schema diagram

dataset – Contains CSVs
