/*******************************************************************************
Initialize the star schema 
********************************************************************************/
-- 1. Drop the star schema if it already exists.
-- 2. Create the star schema. 
-- 3. Use the star schema in this file.

DROP SCHEMA IF EXISTS MyTunes_dim;
CREATE SCHEMA Mytunes_dim;
USE MyTunes_dim;

/*******************************************************************************
Create & populate the dimension tables
********************************************************************************/
-- The following tables have been constructed taking into account the following question: 
-- "Does this representation easily support the creation of metrics for our business needs?

-- In each dimension table, we kept the id from the transactional db (business key) 
-- and we added a suggorate key (technical key) that is used to store the history of dimensions. 
-- We also added, except for the time dimension, valid_from & valid_to attributes. We use them to indicate 
-- when a row was inserted and when a row is not valid anymore (deleted or updated and thus replaced).

-- Customer dimension
CREATE TABLE IF NOT EXISTS customer_dim( 
	customer_key INT AUTO_INCREMENT PRIMARY KEY, 
	customer_id INT NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    company VARCHAR(80),
    address VARCHAR(70),
    city VARCHAR(40),
    state VARCHAR(40),
    country VARCHAR(40),
    postalcode VARCHAR(10),
    phone VARCHAR(24),
    fax VARCHAR(24),
    email VARCHAR(60),
    valid_from DATETIME NOT NULL DEFAULT NOW(),
    valid_to DATETIME NOT NULL DEFAULT '9999-12-31 00:00:00'
);
INSERT INTO customer_dim (customer_id, first_name, last_name, company, address, city, state, country, postalcode, phone, fax, email)
SELECT CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax, Email 
FROM MyTunes.Customer;

-- Track dimension : This table also contains the data needed to compute the sales by artist and by album. 
-- We have decided to put the information from the tables track, album and artist together to keep ou star schema more simple.
CREATE TABLE IF NOT EXISTS track_dim(
	track_key INT AUTO_INCREMENT PRIMARY KEY,
    track_id INT NOT NULL,
    name VARCHAR(200),
    unit_price NUMERIC(10,2) NOT NULL,
    composer VARCHAR(220),
    albumId INT NOT NULL, 
    album_title VARCHAR(160),
    artistId INT NOT NULL, 
    artist_name VARCHAR(120),
    valid_from DATETIME NOT NULL DEFAULT NOW(),
    valid_to DATETIME NOT NULL DEFAULT '9999-12-31 00:00:00'
);
INSERT INTO track_dim (track_id, name, unit_price, composer, albumId, album_title, artistId, artist_name)
SELECT tr.TrackId, tr.Name, tr.UnitPrice, tr.Composer, tr.AlbumId, al.Title, al.ArtistId, ar.Name
FROM MyTunes.Track tr
	INNER JOIN Mytunes.Album al ON tr.AlbumId = al.AlbumId
	INNER JOIN Mytunes.Artist ar ON al.ArtistId = ar.ArtistId;

-- Invoice dimension: we decided to keep only the country granularity level as sales only need to be computed by country.
CREATE TABLE IF NOT EXISTS invoice_dim(
	invoice_key INT AUTO_INCREMENT PRIMARY KEY,
	invoice_id INT NOT NULL,
    billing_country VARCHAR(40),
	invoice_date DATETIME,
    total DECIMAL (10,2),
    valid_from DATETIME NOT NULL DEFAULT NOW(),
    valid_to DATETIME NOT NULL DEFAULT '9999-12-31 00:00:00'
);
INSERT INTO invoice_dim (invoice_id, billing_country, invoice_date, total)
SELECT InvoiceId, BillingCountry, InvoiceDate, Total 
FROM MyTunes.Invoice;

-- Time dimension : This table contains the time dimension with a granularity up to the day as required.
CREATE TABLE IF NOT EXISTS time_dim(
time_key INT auto_increment PRIMARY KEY,
day INT NOT NULL,
month INT NOT NULL,
year INT NOT NULL,
quarter INT NOT NULL
);
INSERT INTO time_dim(day, month, year, quarter)
SELECT DISTINCT day(InvoiceDate), month(InvoiceDate), year(InvoiceDate), quarter(InvoiceDate) 
FROM MyTunes.Invoice;

/*******************************************************************************
Create the fact table
********************************************************************************/
-- We have also created a suggorate key here and added all the foreign keys of the dimension tables to link them to the fact table.
-- We inserted a measure that corresponds to the total number of sales. With this measure, we can compute the sales by 
-- billingCountry, by artist, by album and by customer (and up to the day granularity) with simple queries (provided below).

CREATE TABLE IF NOT EXISTS fct_sales(
	fct_sales_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_key INT NOT NULL, 
    track_key INT NOT NULL,
    invoice_key INT NOT NULL,
    time_key INT NOT NULL,
    sales FLOAT NOT NULL,
    FOREIGN KEY(customer_key) REFERENCES customer_dim(customer_key),
    FOREIGN KEY(track_key) REFERENCES track_dim(track_key),
    FOREIGN KEY(invoice_key) REFERENCES invoice_dim(invoice_key),
    FOREIGN KEY(time_key) REFERENCES time_dim(time_key)
);
INSERT INTO fct_sales(customer_key, track_key, invoice_key, time_key, sales)
SELECT cd.customer_key, trd.track_key, id.invoice_key, td.time_key, s.sales
FROM (SELECT I.CustomerId, Il.TrackId, I.InvoiceId,  year(I.InvoiceDate) AS year, quarter(I.InvoiceDate) AS quarter, month(I.InvoiceDate) AS month, 
			 day(I.InvoiceDate) AS day, SUM(Il.Quantity * Il.UnitPrice) AS sales
		FROM MyTunes.Invoice I
			INNER JOIN MyTunes.InvoiceLine Il ON (Il.InvoiceId = I.InvoiceId)
		GROUP BY I.CustomerId, Il.TrackId, I.InvoiceId, year(I.InvoiceDate), quarter(I.InvoiceDate), month(I.InvoiceDate), day(I.InvoiceDate)) s
    INNER JOIN time_dim td ON (td.year = s.year AND td.quarter = s.quarter AND td.month = s.month AND td.day = s.day)
    INNER JOIN customer_dim cd ON (cd.customer_id = s.CustomerId AND cd.valid_to = '9999-12-31 00:00:00') 
    INNER JOIN track_dim trd ON (trd.track_id = s.TrackId AND trd.valid_to = '9999-12-31 00:00:00')          
	INNER JOIN invoice_dim id ON (id.invoice_id = s.InvoiceId AND id.valid_to = '9999-12-31 00:00:00');
    
    
/*******************************************************************************
Results of the different queries requested in phase 1
********************************************************************************/
-- The following queries give us the sales per country, artist, album or customer as required. 
-- We can also order them by month, year,quarter or day. We just need to add this command line: 
-- INNER JOIN time_dim td ON fs.time_key = td.time_key and GROUP BY the time we want.

USE MyTunes_dim;

-- Sales per billing country
SELECT id.billing_country AS Country, ROUND(SUM(sales),2) AS sales
FROM fct_sales fs
	INNER JOIN invoice_dim id ON fs.invoice_key = id.invoice_key
GROUP BY id.billing_country;

-- Sales per album
SELECT trd.album_title AS Album, ROUND(SUM(sales),2) AS sales
FROM fct_sales fs
	INNER JOIN track_dim trd ON fs.track_key = trd.track_key
GROUP BY trd.album_title;

-- Sales per artist
SELECT trd.artist_name AS Artist, ROUND(SUM(sales),2) AS sales
FROM fct_sales fs
	INNER JOIN track_dim trd ON fs.track_key = trd.track_key
GROUP BY trd.artist_name;

-- Sales per customer
SELECT cd.first_name AS Customer, ROUND(SUM(sales),2) AS sales
FROM fct_sales fs
	INNER JOIN customer_dim cd ON fs.customer_key = cd.customer_key
GROUP BY cd.first_name;
