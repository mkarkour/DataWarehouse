USE MyTunes;
-- The Album "American Idiot" was wrongly assigned to the Artist 'David Coverdale' instead of 'Green Day'
UPDATE album SET ArtistId = 54 WHERE AlbumId = 89;

-- The band Apocalyptica has released a new album and they realised that they are becoming more popular and increased the price of their old album by €0.25 per track
INSERT INTO album (Title, ArtistId) VALUES ('Cell-0', 7);
INSERT INTO track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice)  VALUES ('Ashes of the Modern World', (select AlbumId from album where Title = 'Cell-0'), 1, 3, 'Apocalyptica', 389716, 12808195, 1.24);
INSERT INTO track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice)  VALUES ('Cell-0', (select AlbumId from album where Title = 'Cell-0'), 1, 3, 'Apocalyptica', 597156, 19625806, 1.24);
INSERT INTO track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice)  VALUES ('Rise', (select AlbumId from album where Title = 'Cell-0'), 1, 3, 'Apocalyptica', 322699, 10605651, 1.24);
INSERT INTO track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice)  VALUES ('En Route to Mayhem', (select AlbumId from album where Title = 'Cell-0'), 1, 3, 'Apocalyptica', 328555, 10798111, 1.24);
INSERT INTO track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice)  VALUES ('Call My Name', (select AlbumId from album where Title = 'Cell-0'), 1, 3, 'Apocalyptica', 235784, 7749149, 1.24);
INSERT INTO track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice)  VALUES ('Fire & Ice', (select AlbumId from album where Title = 'Cell-0'), 1, 3, 'Apocalyptica', 321741, 10574165, 1.24);
INSERT INTO track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice)  VALUES ('Scream for the Silent', (select AlbumId from album where Title = 'Cell-0'), 1, 3, 'Apocalyptica', 312314, 10264343, 1.24);
INSERT INTO track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice)  VALUES ('Catharsis', (select AlbumId from album where Title = 'Cell-0'), 1, 3, 'Apocalyptica', 298098, 9797127, 1.24);
INSERT INTO track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice)  VALUES ('Beyond the Stars', (select AlbumId from album where Title = 'Cell-0'), 1, 3, 'Apocalyptica', 414490, 13622404, 1.24);

UPDATE track SET UnitPrice = 1.24 WHERE AlbumId IN (select AlbumId from album where ArtistId = 7);

-- Customer 15 changes from job and goes to a different company and buys a few new tracks
UPDATE customer SET Company = 'HEC Montreal', Address='3000 Côte-Sainte-Catherine Road', City='Montreal', State='PQ', PostalCode='H3T 2A7', email='jennifer.peterson@hec.ca' WHERE CustomerId = 15;
INSERT INTO invoice (CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total)  VALUES (15, NOW(), '3000 Côte-Sainte-Catherine Road', 'Montreal', 'PQ', 'Canada', 'H3T 2A7', 15.35);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1133, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1134, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1135, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1136, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1137, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1138, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1139, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1140, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1141, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1142, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1143, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1144, 0.99, 1);
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 1145, 0.99, 1); 
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), (select TrackId from track where Name = 'Cell-0'), 1.24, 1); 
INSERT INTO invoiceline (InvoiceId, TrackId, UnitPrice, Quantity) VALUES ((select InvoiceId from invoice where BillingAddress = '3000 Côte-Sainte-Catherine Road' and CustomerId = 15), 78, 1.24, 1); 




