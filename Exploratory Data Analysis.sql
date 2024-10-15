
-- Exploratory Data Analysis

SELECT * FROM layoff_work;

-- Which company laid off all their employees on the same day?
SELECT MAX(percentage_laid_off) 
FROM layoff_work;

SELECT *
FROM layoff_work
WHERE percentage_laid_off = 1;

-- Which company has the maximum laid off numbers in a single day?
SELECT MAX(total_laid_off) 
FROM layoff_work;

SELECT *
FROM layoff_work
WHERE total_laid_off = 12000;

-- Which country has the maximum laid off employees?
SELECT country, SUM(total_laid_off)
FROM layoff_work
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

-- What date range of layoff does the dataset hold ?
SELECT MIN(`date`), MAX(`date`)
FROM layoff_work;

-- Which year has the most number of layoff?
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoff_work
GROUP BY YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC;

 -- Which industry was affected the most?
 SELECT industry, SUM(total_laid_off)
 FROM layoff_work
 GROUP BY industry
 ORDER BY SUM(total_laid_off) DESC;
 
 -- The stage with the maximum layoff?
 SELECT stage, SUM(total_laid_off)
 FROM layoff_work
 GROUP BY stage
 ORDER BY SUM(total_laid_off) DESC;
 
 -- Highest layoffs monthwise
 SELECT YEAR(`date`), MONTH(`date`), SUM(total_laid_off)
 FROM layoff_work
 GROUP BY YEAR(`date`), MONTH(`date`)
 ORDER BY SUM(total_laid_off) DESC;
 
 -- Progression of layoff over each month
 WITH cte AS(
 SELECT YEAR(`date`) AS `year`, MONTH(`date`) AS `month`, SUM(total_laid_off) AS total_laidoff
 FROM layoff_work
 WHERE YEAR(`date`) IS NOT NULL
 GROUP BY YEAR(`date`), MONTH(`date`)
 ORDER BY YEAR(`date`), MONTH(`date`)
 )
 SELECT `year`, `month`, total_laidoff, 
 SUM(total_laidoff) OVER(ORDER BY `year`, `month`) AS rolling_total_laid_off
 FROM cte;
 
 -- Top 5 companies who laid off the most yearwise
WITH cte AS(  
SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS total_laidoff, 
DENSE_RANK() OVER(PARTITION BY YEAR(`date`) ORDER BY SUM(total_laid_off) DESC) AS laidoff_rank
FROM layoff_work
GROUP BY company, YEAR(`date`)
ORDER BY company ASC
)
SELECT *
FROM cte
WHERE year IS NOT NULL
AND laidoff_rank <= 5
ORDER BY `year`, laidoff_rank;
  
  
  
-- The company who laid off the most each year
WITH cte AS(  
SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS total_laidoff, 
DENSE_RANK() OVER(PARTITION BY YEAR(`date`) ORDER BY SUM(total_laid_off) DESC) AS laidoff_rank
FROM layoff_work
GROUP BY company, YEAR(`date`)
ORDER BY company ASC
)
SELECT *
FROM cte
WHERE `year` IS NOT NULL
AND laidoff_rank = 1
ORDER BY `year`;  
  
  
  