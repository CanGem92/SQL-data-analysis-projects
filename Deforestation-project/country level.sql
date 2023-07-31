--country level

--top 5 countries by forest area increase

WITH country_90 AS
		(SELECT country_name, region, forest_area_sqkm AS forest_area_90, year
		  FROM forestation
		  WHERE year = 1990),
     country_16 AS
      	(SELECT country_name, forest_area_sqkm AS forest_area_16, year
		  FROM forestation
		  WHERE year = 2016)
SELECT c90.country_name, c90.region, c16.forest_area_16 - c90.forest_area_90 AS forest_area_increase
FROM country_90 c90
JOIN country_16 c16
USING (country_name)
WHERE country_name != 'World' AND (c16.forest_area_16 - c90.forest_area_90) IS NOT NULL
ORDER BY forest_area_increase DESC
LIMIT 5;


----top 5 countries by percentage of forest area

WITH country_90 AS
		(SELECT country_name, region, forest_area_sqkm AS forest_area_90, year
		  FROM forestation
		  WHERE year = 1990),
     country_16 AS
      	(SELECT country_name, forest_area_sqkm AS forest_area_16, year
		  FROM forestation
		  WHERE year = 2016)
SELECT c90.country_name, c90.region, 
       ROUND(((c16.forest_area_16 - c90.forest_area_90)*100/c90.forest_area_90)::numeric,2) AS forest_area_percentage_increase
FROM country_90 c90
JOIN country_16 c16
USING (country_name)
WHERE country_name != 'World' AND (c16.forest_area_16 - c90.forest_area_90) IS NOT NULL
ORDER BY forest_area_percentage_increase DESC
LIMIT 5;

--top 5 countries by forest area loss

WITH country_90 AS
		(SELECT country_name, region, forest_area_sqkm AS forest_area_90, year
		  FROM forestation
		  WHERE year = 1990),
     country_16 AS
      	(SELECT country_name, forest_area_sqkm AS forest_area_16, year
		  FROM forestation
		  WHERE year = 2016)
SELECT c90.country_name, c90.region, c16.forest_area_16 - c90.forest_area_90 AS forest_area_loss
FROM country_90 c90
JOIN country_16 c16
USING (country_name)
WHERE country_name != 'World'
ORDER BY forest_area_loss
LIMIT 5) t;

--top 5 countries by percentage of lost forest area

WITH country_90 AS
		(SELECT country_name, region, forest_area_sqkm AS forest_area_90, year
		  FROM forestation
		  WHERE year = 1990),
     country_16 AS
      	(SELECT country_name, forest_area_sqkm AS forest_area_16, year
		  FROM forestation
		  WHERE year = 2016)
SELECT c90.country_name, c90.region, 
       ROUND(((c16.forest_area_16 - c90.forest_area_90)*100/c90.forest_area_90)::numeric,2) AS forest_area_percentage_decrease
FROM country_90 c90
JOIN country_16 c16
USING (country_name)
WHERE country_name != 'World' AND (c16.forest_area_16 - c90.forest_area_90) IS NOT NULL
ORDER BY forest_area_percentage_decrease
LIMIT 5;

--quartiles for percentage of forest area

SELECT 
     CASE WHEN forest_area_percentage < 25 THEN '0-25%'
          WHEN forest_area_percentage BETWEEN 25 AND 50 THEN '25%-50%'
          WHEN forest_area_percentage BETWEEN 50 AND 75 THEN '50%-75%'
          ELSE '75%-100%'
      END AS quartiles,
      COUNT(*) number_of_countries
FROM forestation
WHERE year = 2016 AND country_name != 'World' AND forest_area_percentage IS NOT NULL
GROUP BY 1
ORDER BY 1

--countries in the top quartile

SELECT country_name, region, forest_area_percentage
FROM forestation
WHERE year= 2016 AND forest_area_percentage > 75
ORDER BY 3 DESC

--number of countries with higher forestation percentage than US in 2016

SELECT COUNT(*) AS number_of_countries_with_higher_percentage_than_usa
FROM forestation
WHERE year = 2016 
  AND country_name != 'World'
  AND forest_area_percentage > (SELECT forest_area_percentage 
								FROM forestation
								WHERE year =2016 
								AND country_name = 'United States');

