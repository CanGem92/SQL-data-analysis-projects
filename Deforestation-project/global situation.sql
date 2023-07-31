--https://learn.udacity.com/paid-courses/cd12500/lessons/981ffcbd-fe99-4667-a0e2-d92244825aed/concepts/96dac666-8efc-4226-a5e6-397af376d6ab

--global situation

--total forest area for 1990, 2016, forest area loss and percentage of area loss

WITH area_90 AS
			(SELECT country_name, forest_area_sqkm
			FROM forestation
			WHERE country_name = 'World' AND year = 1990),
		area_16 AS
			(SELECT country_name, forest_area_sqkm
			FROM forestation
			WHERE country_name = 'World' AND year = 2016)
SELECT a90.forest_area_sqkm AS forest_area_1990, a16.forest_area_sqkm AS forest_area_2016,
			 a16.forest_area_sqkm - a90.forest_area_sqkm AS area_loss,
			 ROUND(((a16.forest_area_sqkm / a90.forest_area_sqkm - 1)*100)::numeric,2) AS lost_area_percentage
FROM area_16 a16
JOIN area_90 a90
	 USING (country_name);


--comparison of forest area loss to total country land area in 2016

SELECT country_name, total_land_area_sqkm
FROM forestation
WHERE year = 2016
ORDER BY ABS(total_land_area_sqkm - 1324449)
LIMIT 1;