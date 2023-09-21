USE MyTunes;
-- UNDO
UPDATE album SET ArtistId = 55 WHERE AlbumId = 89;
UPDATE customer SET Company = 'Rogers Canada', Address='700 W Pender Street', City='Vancouver', State='BC', PostalCode='V6C 1G8', email='jenniferp@rogers.ca' WHERE CustomerId = 15;
DELETE FROM invoiceline WHERE InvoiceId in (select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15);
DELETE FROM invoice WHERE CustomerId = 15 and BillingAddress = '3000 Côte-Sainte-Catherine Road';
UPDATE track SET UnitPrice = 0.99 WHERE AlbumId IN (select AlbumId from album where ArtistId = 7);
DELETE FROM track WHERE AlbumId in (select AlbumId from album where Title = 'Cell-0' and ArtistId = 7);
DELETE FROM album WHERE Title = 'Cell-0' and ArtistId = 7;


