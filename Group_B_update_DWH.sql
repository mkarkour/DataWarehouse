USE MyTunes_dim;

-- Update methodology
-- 1) Creation of the stagging tables (copy of transactional tables) in the star schema to avoid to put extra charge on the transactional db.
-- 2) Creation of a temporary table: looking first at rows needed to be updated (by comparing the stagging table with the dimension table).
-- We only compare to still valid records and we save them in a temporary table.
-- 3) Update of the concerned dimension table and change of the valid_to field for records not valid anymore.
-- 4) Update of the time dimension if necessary.
-- 5) Update of the fact table if necessary.

/****************************************************************************************************************
Update 1: The Album "American Idiot" was wrongly assigned to the Artist 'David Coverdale' instead of 'Green Day'.
*****************************************************************************************************************/

-- Stagging table
DROP TABLE IF EXISTS stg_album;
CREATE TABLE stg_album(
SELECT * FROM MyTunes.album
);

-- Temporary table
SELECT * 
FROM MyTunes_dim.track_dim tr
	LEFT JOIN MyTunes.album a ON a.AlbumId = tr.albumId
WHERE (tr.Artistid <> a.ArtistId) 
AND tr.valid_to = '9999-12-31 00:00:00';

CREATE TEMPORARY TABLE artist_changed AS
SELECT track_key FROM MyTunes_dim.track_dim tr
	LEFT JOIN stg_album a ON a.AlbumId = tr.albumId
WHERE tr.artistId <> a.ArtistId 
AND tr.valid_to = '9999-12-31 00:00:00';

SELECT * FROM artist_changed; #To check the changes for artists

-- Updating the track dimension
#1) Adding changed records
INSERT INTO track_dim (artistId,track_id, albumId, name, composer, unit_price, album_title, artist_name) 
SELECT al.artistId, tr.track_id, tr.albumId, tr.name, tr.composer, tr.unit_price, tr.album_title, tr.artist_name 
FROM stg_album al
	LEFT JOIN track_dim tr ON al.albumId = tr.albumId
WHERE (tr.artistId <> al.artistId)
AND (tr.valid_to = '9999-12-31 00:00:00' OR tr.valid_to IS NULL);

#2) Update the valid_to date of the changed records in the track dimension
UPDATE track_dim 
SET valid_to = NOW()
WHERE track_key IN (SELECT track_key FROM artist_changed);

-- To verify that the update has been correctly done
SELECT * FROM track_dim WHERE albumId = 89;

-- Drop the tempory table 
DROP TABLE artist_changed;

-- Here, the time dimension and the fact table don't need to be updated because there is no new sale to add in the fact table.

/*****************************************************************************************************************************************************************************
Update 2: The band Apocalyptica has released a new album and they realised that they are becoming more popular and increased the price of their old album by €0.25 per track.
******************************************************************************************************************************************************************************/

-- Stagging tables
DROP TABLE IF EXISTS stg_track;
CREATE TABLE stg_track( 
SELECT * FROM MyTunes.track
);

-- Temporary table
SELECT * FROM MyTunes_dim.track_dim tr
	LEFT JOIN MyTunes.track T ON T.TrackId = tr.track_id
WHERE (tr.unit_price <> T.UnitPrice)  
AND tr.valid_to = '9999-12-31 00:00:00';

DROP TABLE IF EXISTS price_changed;
CREATE TEMPORARY TABLE price_changed AS
SELECT track_key FROM MyTunes_dim.track_dim tr
    LEFT JOIN MyTunes.track T ON T.TrackId = tr.track_id
WHERE (tr.unit_price <> T.UnitPrice) 
AND tr.valid_to = '9999-12-31 00:00:00';

SELECT * FROM price_changed; #To check the changes on the price of tracks

#1) Adding new & changed records
-- Updating the track dimension 
INSERT INTO  MyTunes_dim.track_dim (artistId, track_id, albumId, name, unit_price, album_title, artist_name) 
SELECT al.artistId, T.trackId, T.albumId, T.name, T.UnitPrice, tr.album_title, tr.artist_name 
FROM  MyTunes_dim.stg_track T
    LEFT JOIN MyTunes_dim.track_dim tr ON T.TrackId = tr.track_id
    LEFT JOIN MyTunes_dim.stg_album al ON T.AlbumId = al.AlbumId
WHERE tr.unit_price <> T.UnitPrice AND tr.valid_to = '9999-12-31 00:00:00' OR tr.valid_to is NULL;

#2) #Update the valid_to date of the changed records in the dimension
UPDATE  MyTunes_dim.track_dim 
SET valid_to = NOW()
WHERE track_key IN (SELECT track_key FROM price_changed);

-- To verify that the update has been correctly done.
SELECT * FROM  MyTunes_dim.track_dim WHERE artistId=7;

-- Drop the tempory table
DROP TABLE price_changed;

-- Here, the time dimension and the fact table don't need to be updated because there is no new sale to add in the fact table.

/************************************************************************************************
Update 3: Customer 15 changes from job and goes to a different company and buys a few new tracks.
*************************************************************************************************/

-- Stagging tables
DROP TABLE IF EXISTS stg_customer;
CREATE TABLE stg_customer(
SELECT * FROM MyTunes.customer
);

DROP TABLE IF EXISTS stg_invoice;
CREATE TABLE stg_invoice(
SELECT * FROM MyTunes.Invoice
);

DROP TABLE IF EXISTS stg_invoiceLine;
CREATE TABLE stg_invoiceLine(
SELECT * FROM MyTunes.InvoiceLine
);

-- Temporary table
SELECT * 
FROM mytunes_dim.customer_dim cd
	LEFT JOIN MyTunes.customer c ON c.customerid = cd.customer_id
WHERE (cd.company <> c.company OR c.address <> cd.address OR c.city <> cd.city OR c.state <> cd.state OR c.postalcode <> cd.postalcode OR c.email<>cd.email)  
AND cd.valid_to = '9999-12-31 00:00:00';

DROP TABLE IF EXISTS customer_changed;
CREATE TEMPORARY TABLE customer_changed 
SELECT customer_key FROM MyTunes_dim.customer_dim cd
	LEFT JOIN stg_customer sc ON sc.customerid = cd.customer_id
WHERE (sc.company <> cd.company OR sc.address <> cd.address OR sc.city <> cd.city OR sc.state <> cd.state OR sc.postalcode <> cd.postalcode OR sc.email<>cd.email)
AND cd.valid_to = '9999-12-31 00:00:00';

SELECT * FROM customer_changed; #To check the changes for the customer

#1) Adding new & changed records
-- Updating the customer dimension 
INSERT INTO mytunes_dim.customer_dim (customer_id, first_name, last_name, company, address, city, state, country, postalcode, phone, fax, email) 
SELECT sc.CustomerId, sc.FirstName, sc.LastName, sc.Company, sc.Address, sc.City, sc.State, sc.Country, sc.PostalCode, sc.Phone, sc.Fax, sc.Email
FROM stg_customer sc
	LEFT JOIN mytunes_dim.customer_dim cd ON sc.customerid = cd.customer_id
WHERE (cd.company <> sc.company OR sc.address <> cd.address OR sc.city <> cd.city OR sc.state <> cd.state OR sc.postalcode <> cd.postalcode OR sc.email<>cd.email)
AND (cd.valid_to = '9999-12-31 00:00:00' OR cd.valid_to IS NULL);

#2) #Update the valid_to date of the changed records in the dimension 
UPDATE mytunes_dim.customer_dim 
SET valid_to=NOW() 
WHERE customer_key IN (SELECT customer_key FROM customer_changed);

-- To verify that the update has been correctly done.
SELECT * FROM mytunes_dim.customer_dim WHERE customer_id=15;

-- Drop the tempory table
DROP TABLE customer_changed;

#3) Update the time dimension
INSERT INTO time_dim(year, month, day, quarter)
SELECT DISTINCT year(i.InvoiceDate), month(i.InvoiceDate), day(i.InvoiceDate), quarter(i.InvoiceDate)
FROM stg_invoice i
	LEFT JOIN time_dim td ON (year(i.InvoiceDate) = td.year AND month(i.InvoiceDate)= td.month AND day(i.InvoiceDate) = td.day)
WHERE td.quarter is NULL;

#4) Update the invoice dimension (with the new contracted invoice)
INSERT INTO invoice_dim (invoice_id, billing_country, invoice_date, total)
SELECT InvoiceId, BillingCountry, InvoiceDate, si.Total 
FROM stg_invoice si
	LEFT JOIN invoice_dim id ON si.invoiceid = id.invoice_id
WHERE si.invoiceid NOT IN (SELECT invoice_id FROM invoice_dim)
AND (id.valid_to = '9999-12-31 00:00:00' OR id.valid_to IS NULL);

-- 4) Update the fact table: as a customer bought new tracks, the amount of sales have changed and we thus have to update the fact table containing this metric.
SELECT il.invoiceId, SUM(Il.Quantity * Il.UnitPrice) AS sales
FROM stg_invoiceLine il
	INNER JOIN stg_invoice i ON i.invoiceId = il.invoiceId
WHERE i.InvoiceDate >= '2022-05-18 00:00:00'
GROUP BY il.invoiceId;

INSERT INTO MyTunes_dim.fct_sales (customer_key, track_key, invoice_key, time_key, sales)
WITH new_sales AS (
SELECT i.customerId, tr.trackId, i.invoiceId, year(i.InvoiceDate) AS year, month(i.InvoiceDate) AS month, day(i.InvoiceDate) AS day, quarter(i.InvoiceDate) AS quarter, SUM(il.Quantity * il.UnitPrice) AS sales
FROM stg_invoiceLine il
	INNER JOIN stg_invoice i ON i.invoiceId =  il.invoiceId
    INNER JOIN stg_track tr ON tr.trackId = il.trackId 
WHERE i.InvoiceDate >= '2022-05-18 00:00:00'
GROUP BY i.customerId, tr.trackId, i.invoiceId, year(i.InvoiceDate) , month(i.InvoiceDate) , quarter(i.InvoiceDate), day(i.InvoiceDate)
)
SELECT c.customer_key, tr.track_key, i.invoice_key, td.time_key, ns.sales AS sales
FROM new_sales ns
	LEFT JOIN customer_dim c ON c.customer_id = ns.customerId AND c.valid_to = '9999-12-31 00:00:00'
	LEFT JOIN track_dim tr ON tr.track_id = ns.trackId AND tr.valid_to = '9999-12-31 00:00:00'
	LEFT JOIN invoice_dim i ON i.invoice_id = ns.invoiceId AND i.valid_to = '9999-12-31 00:00:00'
	LEFT JOIN time_dim td ON td.year = ns.year AND td.month = ns.month AND td.quarter = ns.quarter AND td.day = ns.day;


-- To check that our fact table has been correctly updated after the different queries above.
SELECT fcts.customer_key,cd.customer_id,ROUND(SUM(sales),2) 
FROM fct_sales fcts 
	LEFT JOIN customer_dim cd ON cd.customer_key=fcts.customer_key 
WHERE cd.customer_id =15;

-- To check the sales after the updates for the customers in the basic scheme.
SELECT c.customerid, ROUND(SUM(il.UnitPrice*il.quantity),2) AS sales
FROM mytunes.customer c
	LEFT JOIN mytunes.invoice i ON c.CustomerId=i.customerid
	LEFT JOIN mytunes.invoiceline il ON il.InvoiceId=i.invoiceid
WHERE c.customerid=15;
