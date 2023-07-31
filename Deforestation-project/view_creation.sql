--https://learn.udacity.com/paid-courses/cd12500/lessons/981ffcbd-fe99-4667-a0e2-d92244825aed/concepts/96dac666-8efc-4226-a5e6-397af376d6ab

--creation of forestation view

DROP VIEW IF EXISTS forestation;
CREATE VIEW forestation AS 
	(SELECT fa.country_code, fa.country_name, r.region, 
	  ROUND(fa.forest_area_sqkm::numeric,1) AS forest_area_sqkm,
	  ROUND((la.total_area_sq_mi *2.59)::numeric,0) AS total_land_area_sqkm,
	  ROUND((fa.forest_area_sqkm/(la.total_area_sq_mi*2.59)*100)::numeric,2) AS forest_area_percentage, 
	  r.income_group, fa.year
	FROM forest_area fa
	JOIN land_area la
		USING (country_code, year)
	JOIN regions r
		USING (country_code));