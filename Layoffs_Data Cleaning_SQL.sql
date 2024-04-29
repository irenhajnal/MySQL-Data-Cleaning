

USE world_layoffs;

SELECT
	*
FROM
	layoffs;

-- 1. Remove Duplicates if any
-- 2. Standardize the Data
-- 3. Null Values and blank values
-- 4. Remove Any Columns

-- Create a new table to keep the raw data as it is. If I make some mistakes I wantto have the raw data available.
CREATE TABLE layoffs_staging
LIKE layoffs_raw_data;

SELECT
	*
FROM
	layoffs_staging;

INSERT layoffs_staging
SELECT
	*
FROM layoffs_raw_data;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------ REMOVE DUPLICATES ---------------------------------------------------------------------------------------

-- Identify Duplicates

SELECT
	*,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM
	layoffs_staging;
 
 -- List the duplicate rows only
 
WITH duplicate_cte AS
(SELECT
	*,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM
	layoffs_staging)
SELECT
	*
FROM duplicate_cte
WHERE
	row_num >1;
    
SELECT
	*
FROM
	layoffs_staging
WHERE
	company = "Casper";

-- Create a copy of the table with the row_number added

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT 
	*
FROM
	layoffs_staging2;
    
INSERT INTO layoffs_staging2
SELECT
	*,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM
	layoffs_staging;
    
SELECT 
	*
FROM
	layoffs_staging2
WHERE 
	row_num >1;
    
DELETE
FROM layoffs_staging2
WHERE row_num >1;
	
SELECT 
    *
FROM
    layoffs_staging2;
    
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------ Standardizing Data ---------------------------------------------------------------------------------------

-- Remove spaces from the company name
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Clean up industry names 
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean up the location column

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

-- 'DÃ¼sseldorf'
-- 'FlorianÃ³polis'
-- 'MalmÃ¶'

UPDATE layoffs_staging2
SET location = REPLACE(location, 'Ã¼', 'u')
              , location = REPLACE(location, 'Ã³', 'o')
              , location = REPLACE(location, 'Ã¶', 'o');

-- Clean up country names

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

--  Change the date values from TEXT to DATE.
SELECT
	*
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = STR_TO_DATE(date,'%d/%m/%Y');

-- Change the data type of the date column from TEXT to DATE

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------ NULL AND BLANK VALUES ---------------------------------------------------------------------------------------

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Populate the missing fields from another row for the same company

SELECT *
FROM layoffs_staging2
WHERE company = 'Juul';

-- Airbnb industry is Travel, Carvana = Transportation, Jull = Consumer

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT 
   t1.company,
   t1.industry,
   t2.industry
FROM
    layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
        AND t1.location = t2.location
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;
  
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
        AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL ;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------  REMOVING DATA ---------------------------------------------------------------------------------------

-- Delete all rows that where both the total_laid_off and the percentage_laid_off column are NULL - 361 rows

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT
	*
FROM
	layoffs_staging2;
    
ALTER TABLE
	layoffs_staging2
DROP COLUMN row_num;
