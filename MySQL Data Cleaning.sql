
-- Dataset source: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Take a look at the table
SELECT *
FROM layoffs;

-- Create a work table to work with so that the raw data wouldn't be affected

-- Below is one way to create the table after which a new column for row number will be created afterwards
CREATE TABLE layoff_work
LIKE layoffs;

-- Another way below: Along with the existing data, a new column for row number is also included
-- using MySQL Create table syntax
CREATE TABLE `layoff_work` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Insert all values from the raw table along with the row number window function
INSERT layoff_work 
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs;


-- Data Cleaning:

-- 1. Remove duplicate data from the dataset

-- Take a look at the duplicate rows using row number
SELECT * FROM layoff_work
WHERE row_num > 1; 

-- Inspecting some of the rows filtered to check if these duplicate entries are legitimate
SELECT *
FROM layoff_work
WHERE company = 'Cazoo';

-- Delete the actual duplicate rows using row number
DELETE
FROM layoff_work
WHERE row_num >1;

-- 2. Standardize the data

-- Take a look at the first column 'company' to check errors
SELECT DISTINCT company
FROM layoff_work;

-- As some companies seem to have unwanted spaces, let us trim those unwanted spaces from all company names
SELECT company, TRIM(company) 
FROM layoff_work;

-- Update the table by removing unwanted spaces
UPDATE layoff_work
SET company = TRIM(company);

-- Take a look at 'industry' column  
SELECT DISTINCT industry
FROM layoff_work
ORDER BY industry;

-- The industry 'Crypto' seems to have few inconsistent values
SELECT *
FROM layoff_work
WHERE industry LIKE 'Crypto%';

-- Update the industry column with the appropiate values
UPDATE layoff_work
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

-- Take a look at the 'country' column
SELECT DISTINCT country
FROM layoff_work
ORDER BY country;

-- The country 'United States' seems to be indistinct
SELECT *
FROM layoff_work
WHERE country LIKE 'United States%';

-- Update the country column by removing unwanted period
UPDATE layoff_work
SET country = TRIM(TRAILING '.' FROM country) 
WHERE country LIKE 'United States%';

-- As the 'date' column is of text type, let us change it into DATE type
UPDATE layoff_work
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoff_work
MODIFY COLUMN `date` DATE;
 
 -- 3. Work with NULL values and empty rows
 
 -- Check each column for NULL or empty date, here let us take a look at the industry column 
 SELECT *
 FROM layoff_work
 WHERE industry IS NULL 
 OR industry = '';
 
 -- Investigating one of the results to check the issue
 SELECT * FROM layoff_work
 WHERE company = 'Airbnb';
 
-- Here 'Airbnb' has 'Travel' in one row while the other one is just not populated, hence the NULL value
 
 -- So, in case a company has the industry populated in one row and not in another row, replace the NUll value with the ones that is populated  
 -- For example, 'Airbnb' is under 'Travel' industry in one row, so we can replace the NULL values in other 'Airbnb' rows with 'Travel' 
 SELECT * FROM layoff_work t1
 JOIN layoff_work t2
 ON t1.company = t2.company
 WHERE (t1.industry IS NULL
 OR t1.industry = '') 
 AND t2.industry IS NOT NULL;
 
 
 -- Update the other rows with NULL incase of empty or no value to make the upcoming update easier
 UPDATE layoff_work
 SET industry = NULL 
 WHERE industry = '';
 
 
 UPDATE layoff_work t1
 JOIN layoff_work t2
 ON t1.company = t2.company
 SET t1.industry = t2.industry
 WHERE t1.industry IS NULL 
 AND t2.industry IS NOT NULL;
 
 
 -- Inspect other NULL values to see if any other rows should be removed
 
 SELECT *
 FROM layoff_work
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL;
 
 -- 4. Drop unwanted columns or rows
 
 -- Delete the row number column created in the first step 
 ALTER TABLE layoff_work
 DROP COLUMN `row_num`;
 
 SELECT *
 FROM layoff_work;
 
 