--regional outlook

--table for regional forest area percentage

SELECT region, 
	   ROUND((SUM(forest_area_sqkm)/SUM(total_land_area_sqkm)*100)::numeric,2) AS percentage_forest_area,
       year
FROM forestation
WHERE year IN (1990, 2016)
GROUP BY region, year
ORDER BY year DESC, region;


--forest area percentage for the world in 1990 and 2016

WITH region_table AS
		(SELECT region, 
	     ROUND((SUM(forest_area_sqkm)/SUM(total_land_area_sqkm)*100)::numeric,2) AS percentage_forest_area,
         year
         FROM forestation
         WHERE year IN (1990, 2016)
         GROUP BY region, year)
SELECT percentage_forest_area AS world_forest_area_percentgae, year
FROM region_table
WHERE region = 'World';

--regions with highest percentage of forest area in 1990 and 2016

WITH region_table AS
		(SELECT region, 
	     ROUND((SUM(forest_area_sqkm)/SUM(total_land_area_sqkm)*100)::numeric,2) AS percentage_forest_area,
         year
         FROM forestation
         WHERE year IN (1990, 2016)
         GROUP BY region, year),
	 max_t AS
		(SELECT MAX(percentage_forest_area) AS highest_percentage, year
		FROM region_table
        GROUP BY year)
SELECT region AS regions_with_highest_percentage, max_t.highest_percentage AS percentage, region_table.year
FROM region_table
JOIN max_t
ON region_table.percentage_forest_area = max_t.highest_percentage AND
   region_table.year = max_t.year;


--regions with lowest percentage of forest area in 1990 and 2016

WITH region_table AS
		(SELECT region, 
	     ROUND((SUM(forest_area_sqkm)/SUM(total_land_area_sqkm)*100)::numeric,2) AS percentage_forest_area,
         year
         FROM forestation
         WHERE year IN (1990, 2016)
         GROUP BY region, year),
     min_t AS
        (SELECT MIN(percentage_forest_area) AS lowest_percentage, year
		FROM region_table
        GROUP BY year)
SELECT region AS regions_with_lowest_percentage, min_t.lowest_percentage AS percentage, region_table.year
FROM region_table
JOIN min_t
ON region_table.percentage_forest_area = min_t.lowest_percentage AND
   region_table.year = min_t.year;

--detect regions whose forest area decreased since 1990

WITH region_90 AS
		(SELECT region, 
	  			 ROUND((SUM(forest_area_sqkm)/SUM(total_land_area_sqkm)*100)::numeric,2) AS percentage_forest_area,
      			 year
		FROM forestation
		WHERE year = 1990
		GROUP BY region, year),
	 region_16 AS
		(SELECT region, 
	  			 ROUND((SUM(forest_area_sqkm)/SUM(total_land_area_sqkm)*100)::numeric,2) AS percentage_forest_area,
      			 year
		FROM forestation
		WHERE year = 2016
		GROUP BY region, year)
SELECT r90.region, r90.percentage_forest_area AS forest_area_percentace_1990,
       r16.percentage_forest_area AS forest_area_percentace_2016
FROM region_16 r16
JOIN region_90 r90
USING (region)
WHERE (r16.percentage_forest_area - r90.percentage_forest_area) < 0;



--ALTERNATIVE TO HAVE MAX AND MIN IN ONE TABLE


WITH region_table AS
		(SELECT region, 
	     ROUND((SUM(forest_area_sqkm)/SUM(total_land_area_sqkm)*100)::numeric,2) percentage_forest_area,
         year
         FROM forestation
         WHERE year IN (1990, 2016)
         GROUP BY region, year),
	 max_t AS
		(SELECT MAX(percentage_forest_area) highest_percentage, year
		FROM region_table
        GROUP BY year),
    min_t AS
       (SELECT MIN(percentage_forest_area) lowest_percentage, year
		 FROM region_table
        GROUP BY year)
SELECT region regions, max_t.highest_percentage percentage, region_table.year
FROM region_table
JOIN max_t
ON region_table.percentage_forest_area = max_t.highest_percentage AND
   region_table.year = max_t.year
UNION ALL
SELECT region, min_t.lowest_percentage percentage, region_table.year
FROM region_table
JOIN min_t
ON region_table.percentage_forest_area = min_t.lowest_percentage AND
   region_table.year = min_t.year;


--ALTERNATIVE TO HAVE MAX AND MIN IN ONE TABLE SEPARATE COLUMNS

WITH region_table AS
		(SELECT region, 
	     ROUND((SUM(forest_area_sqkm)/SUM(total_land_area_sqkm)*100)::numeric,2) percentage_forest_area,
         year
         FROM forestation
         WHERE year IN (1990, 2016)
         GROUP BY region, year),
	 max_t AS
		(SELECT MAX(percentage_forest_area) highest_percentage, year
		FROM region_table
        GROUP BY year),
    min_t AS
      (SELECT MIN(percentage_forest_area) lowest_percentage, year
		FROM region_table
        GROUP BY year)
SELECT region regions, max_t.highest_percentage highest_percentage, 
       NULL lowest_percentage, region_table.year
FROM region_table
JOIN max_t
ON region_table.percentage_forest_area = max_t.highest_percentage AND
   region_table.year = max_t.year
UNION ALL
SELECT region, NULL, min_t.lowest_percentage, region_table.year
FROM region_table
JOIN min_t
ON region_table.percentage_forest_area = min_t.lowest_percentage AND
   region_table.year = min_t.year;
   