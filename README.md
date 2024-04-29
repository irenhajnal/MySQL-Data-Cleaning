## MySQL Data Cleaning

### Project Overview
Purpose of the project is to identify, correct and handle inaccuracies, inconsistencies, and errors within the dataset.

### Data Source
World Layoffs: The dataset used for this analysis is the "World_layoffs.csv" file containing information about layoffs at global companies between March 2020 and March 2023. The dataset has 9 columns and 2,362 rows.
|Field Name|Data type|
|-----------|---------|
|company|text|
|location|text|
|industry|text|
|total_laid_off|int|
|percentage_laid_off|text|
|date|text|
|stage|text|
|country|text|
|funds_raised_millions|int|

### 1. Removing Duplicates
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#### Checking the data for duplicates

      SELECT
        	*,
            ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
        FROM
        	layoffs_staging;
 
#### Listing the duplicate rows
 
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
  
  <img width="446" alt="image" src="https://github.com/irenhajnal/MySQL-Data-Cleaning/assets/122035130/b47ae9c6-6380-4392-aa46-f01519f465d7">

#### Deleting the duplicates

      DELETE
      FROM layoffs_staging2
      WHERE row_num >1;

### 2. Standardizing Data
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#### Remove spaces from the company name
            UPDATE layoffs_staging2
            SET company = TRIM(company);

#### Clean up industry names
       
        SELECT *
        FROM layoffs_staging2
        WHERE industry LIKE 'Crypto%';
        
        UPDATE layoffs_staging2
        SET industry = 'Crypto'
        WHERE industry LIKE 'Crypto%';
        
#### Clean up location names 'DÃ¼sseldorf' 'FlorianÃ³polis' and'MalmÃ¶'
              UPDATE layoffs_staging2
              SET location = REPLACE(location, 'Ã¼', 'u')
              , location = REPLACE(location, 'Ã³', 'o')
              , location = REPLACE(location, 'Ã¶', 'o');
              
#### Clean up country names
              UPDATE layoffs_staging2
              SET country = TRIM(TRAILING '.' FROM country)
              WHERE country LIKE 'United States%';

#### Change the date values from TEXT to DATE.
              SELECT
              	*
              FROM layoffs_staging2;
              
              UPDATE layoffs_staging2
              SET date = STR_TO_DATE(date,'%d/%m/%Y');

#### Change the data type of the date column from TEXT to DATE
              ALTER TABLE layoffs_staging2
              MODIFY COLUMN date DATE;

### 2. Handle Null and Blank Values
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#### Filling Missing *'industry'* Values

            UPDATE layoffs_staging2 t1
            JOIN layoffs_staging2 t2
            	ON t1.company = t2.company
                    AND t1.location = t2.location
            SET t1.industry = t2.industry
            WHERE
                t1.industry IS NULL
                    AND t2.industry IS NOT NULL ;

### 2. Removing Data
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#### Delete all rows where both the total_laid_off and the percentage_laid_off columns are NULL
            DELETE
            FROM layoffs_staging2
            WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
            
#### Delete the row_num helper column, added earlier to identify duplicates

            ALTER TABLE
            	layoffs_staging2
            DROP COLUMN row_num;

