# MyTunes Data Warehouse Project

## Description
This project focuses on building a Data Warehouse for MyTunes, an online music platform. The goal is to analyze past sales data to gain insights and support decision-making.

## Customer Overview
- **Customer:** MyTunes
- **Business:** Online music platform for purchasing and listening to digital music.
- **Geographic Presence:** 24 countries since 2017.
- **Size:** Currently small in terms of turnover and clients.

## Project Scope

### Phase 1
- **Objective:** Import the transactional database and create a star schema for sales analysis.
- **Database Import:** Utilize the `MyTunes.sql` script for database import.
- **Star Schema:** Design a star schema that allows analysis of song sales.
- **Dimensions:** Include at least 3 dimensions, with dimensions for tracks and customers.
- **Time Granularity:** Enable analysis up to the day.
- **Queries:** Implement queries for sales per artist, album, customer, and BillingCountry per day, month, quarter, and year.

### Phase 2
- **Objective:** Create a script for updating the star schema when changes occur in the transactional source system.
- **Implementation:** Develop and execute the update script.
- **Validation:** Ensure the data warehouse remains consistent after updates.
- **Recovery:** An undoing script is provided in case of issues or errors.

## Getting Started
Follow these steps to get started with the project:

1. Clone this repository to your local machine.
2. Execute the `MyTunes.sql` script to import the transactional database.
3. Design and implement the star schema as per Phase 1 requirements.
4. Develop the update script for Phase 2.
5. Run the update script to validate data warehouse consistency.

## Project Structure
- `MyTunes.sql`: Transactional database import script.
- `star_schema_design.sql`: Star schema design script.
- `update_script.sql`: Script for updating the data warehouse.
- `undo_script.sql`: Undoing script (use in case of issues).

