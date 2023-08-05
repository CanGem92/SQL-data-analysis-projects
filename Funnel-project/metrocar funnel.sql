--How many times was the app downloaded? 23608
SELECT COUNT(*)
FROM app_downloads 

--How many users signed up on the app? 17623
SELECT COUNT(*)
FROM signups

--How many rides were requested through the app? 385477
SELECT COUNT(*)
FROM ride_requests

--How many rides were requested and completed through the app? 223652
SELECT COUNT(dropoff_ts)
FROM ride_requests

--How many rides were requested and how many unique users requested a ride? 12406
SELECT COUNT(DISTINCT user_id)
FROM ride_requests

--What is the average time of a ride from pick up to drop off? 52min 36 seconds
SELECT AVG(dropoff_ts - pickup_ts)
FROM ride_requests

----How many rides were accepted by a driver? 248379
SELECT COUNT(accept_ts)
FROM ride_requests

--How many rides did we successfully collect payments and how much was collected? 212628 4251667.61
SELECT COUNT(*), SUM(purchase_amount_usd)
FROM transactions
WHERE charge_status =  'Approved'

--How many ride requests happened on each platform? android:112317, "ios" :234693, "web" :"38467"
SELECT platform, COUNT(*)
FROM ride_requests
JOIN signups
USING (user_id)
JOIN app_downloads
ON session_id = app_download_key
GROUP BY 1

--What is the drop-off from users signing up to users requesting a ride? 29.6%
WITH s AS (
  		SELECT COUNT(*) AS num_signups
  		FROM signups),
 	r AS (
  		SELECT COUNT(DISTINCT user_id) AS num_requests
       	FROM ride_requests)
SELECT (num_signups-num_requests)/num_signups::numeric
FROM s, r

----How many unique users requested a ride through the Metrocar app? 12406
SELECT COUNT(DISTINCT user_id)
FROM ride_requests

--How many unique users completed a ride through the Metrocar app? 6233
SELECT COUNT(DISTINCT user_id)
FROM ride_requests
WHERE dropoff_ts IS NOT NULL

--Of the users that signed up on the app, what percentage these users requested a ride? 70.4%
WITH s AS (
  		SELECT COUNT(*) AS numb_signups
  		FROM signups),
     r AS (
       	SELECT COUNT(DISTINCT user_id) AS numb_requests
       	FROM ride_requests)
SELECT numb_requests/numb_signups::numeric
FROM s, r

--Of the users that signed up on the app, what percentage these users completed a ride? 35.4%
WITH s AS (
  		SELECT COUNT(*) AS numb_signups
  		FROM signups),
     c AS (
       	SELECT COUNT(DISTINCT user_id) AS numb_complete
       	FROM ride_requests
     	WHERE dropoff_ts IS NOT NULL)
SELECT numb_complete/numb_signups::numeric
FROM s, c

--Using the percent of previous approach, what are the user-level conversion rates for the first 3 stages of the funnel (app download to signup and signup to ride requested)?  74.6% 70.4%
WITH d AS (
  		SELECT COUNT(*) AS numb_downloads
  		FROM app_downloads),
	s AS (
  		SELECT COUNT(*) AS numb_signups
  		FROM signups),
     r AS (
		SELECT COUNT(DISTINCT user_id) AS numb_requests
  		FROM ride_requests)
SELECT numb_signups/numb_downloads::numeric AS first_stage, numb_requests/numb_signups::numeric AS second_stage
FROM d, s, r

--Using the percent of top approach, what are the user-level conversion rates for the first 3 stages of the funnel (app download to signup and signup to ride requested)?  74.6% 52.5%
WITH d AS (
  		SELECT COUNT(*) AS numb_downloads
  		FROM app_downloads),
	s AS (
  		SELECT COUNT(*) AS numb_signups
  		FROM signups),
     r AS (
  	SELECT COUNT(DISTINCT user_id) AS numb_requests
	FROM ride_requests)
SELECT numb_signups/numb_downloads::numeric AS first_stage, numb_requests/numb_downloads::numeric AS second_stage
FROM d, s, r

--Using the percent of previous approach, what are the user-level conversion rates for the following 3 stages of the funnel? 1. signup, 2. ride requested, 3. ride completed 70.4% 50.2%
WITH s AS (
  		SELECT COUNT(*) AS numb_signups
  		FROM signups),
     r AS (
     	SELECT COUNT(DISTINCT user_id) AS numb_requests
  		FROM ride_requests),
     c AS (
       	SELECT COUNT(DISTINCT user_id) AS numb_complete
       	FROM ride_requests
     	WHERE dropoff_ts IS NOT NULL)
SELECT numb_requests/numb_signups::numeric AS first_stage, numb_complete/numb_requests::numeric AS second_stage
FROM s, r, c

--Using the percent of top approach, what are the user-level conversion rates for the following 3 stages of the funnel? 1. signup, 2. ride requested, 3. ride completed 70.4% 35.4%
WITH s AS (
  		SELECT COUNT(*) AS numb_signups
  		FROM signups),
     r AS (
       	SELECT COUNT(DISTINCT user_id) AS numb_requests
       	FROM ride_requests),
     c AS (
       	SELECT COUNT(DISTINCT user_id) AS numb_complete
       	FROM ride_requests
     	WHERE dropoff_ts IS NOT NULL)
SELECT numb_requests/numb_signups::numeric AS first_stage, numb_complete/numb_signups::numeric AS second_stage
FROM s, r, c

--percentage of downloads by platform
SELECT platform, COUNT(*)/(SELECT COUNT(*) AS downloads
                           FROM app_downloads)::numeric
FROM app_downloads 
GROUP BY 1

--Average purchase amount by platform
SELECT platform, AVG(purchase_amount_usd)
FROM transactions t
JOIN ride_requests
USING (ride_id)
JOIN signups
USING (user_id)
JOIN app_downloads
ON app_download_key= session_id 
GROUP BY 1

--percentage of signups by age range
SELECT age_range, COUNT(*)/(SELECT COUNT(*) 
                           FROM signups)::numeric
FROM signups 
GROUP BY 1

--Average purchase amount by age range
SELECT age_range, AVG(purchase_amount_usd)
FROM transactions t
JOIN ride_requests
USING (ride_id)
JOIN signups
USING (user_id)
GROUP BY 1

--create user funnel temp table
WITH d AS (
           SELECT COUNT(*) AS numb_downloads
          FROM app_downloads),
     s AS (
          SELECT COUNT(*) AS numb_signups
          FROM signups),
     r AS (
          SELECT COUNT(DISTINCT user_id) AS numb_requests
          FROM ride_requests),
     a AS (
          SELECT COUNT(DISTINCT user_id) AS numb_accepted
          FROM ride_requests
          WHERE accept_ts IS NOT NULL),
     P AS (
          SELECT COUNT(DISTINCT user_id) AS numb_pickups
          FROM ride_requests
          WHERE pickup_ts IS NOT NULL),
     t AS (
          SELECT COUNT(DISTINCT user_id) AS numb_transactions
          FROM transactions
          JOIN ride_requests
          USING(ride_id)
          WHERE charge_status = 'Approved'),
     rv AS (
          SELECT COUNT(DISTINCT user_id) AS numb_reviews
          FROM reviews)
SELECT 0 as step, 'downloads' as stage, numb_downloads as count 
FROM d
UNION
SELECT 1, 'signups', numb_signups
FROM s
UNION
SELECT 2, 'requests', numb_requests
FROM r
UNION
SELECT 3, 'accepted rides', numb_accepted
FROM a
UNION
SELECT 4, 'completed rides', numb_pickups
FROM p
UNION
SELECT 5, 'approved transactions', numb_transactions
FROM t
UNION
SELECT 6, 'reviews', numb_reviews
FROM rv
ORDER BY step

--calculate percent previous and percent top
SELECT step, count, lag(count) OVER(), (count/lag(count) OVER()::numeric) AS conv_rate
FROM funnel
SELECT step, count, first_value(count) OVER(), (count/first_value(count) OVER()::numeric) AS conv_rate
FROM funnel


--create ride funnel temp table
CREATE temp table ridefunnel as 
WITH r AS (
          SELECT COUNT(*) AS numb_requests
          FROM ride_requests),
     a AS (
          SELECT COUNT(*) AS numb_accepted
          FROM ride_requests
          WHERE accept_ts IS NOT NULL),
     p AS (
          SELECT COUNT(*) AS numb_pickups
          FROM ride_requests
          WHERE pickup_ts IS NOT NULL),
     t AS (
          SELECT COUNT(DISTINCT ride_id) AS numb_transactions
          FROM transactions
          WHERE charge_status = 'Approved'),
     rv AS (
          SELECT COUNT(DISTINCT ride_id) AS numb_reviews
          FROM reviews)
SELECT 0 as step, 'requests' AS stage, numb_requests AS count
FROM r
UNION
SELECT 1, 'accepted rides', numb_accepted
FROM a
UNION
SELECT 2, 'completed rides', numb_pickups
FROM p
UNION
SELECT 3, 'approved transactions', numb_transactions
FROM t
UNION
SELECT 4, 'reviews', numb_reviews
FROM rv
ORDER BY step 

--calculate percent previous and percent top
SELECT step, count, lag(count) OVER(), (count/lag(count) OVER()::numeric) AS conv_rate
FROM ridefunnel
SELECT step, count, first_value(count) OVER(), (count/first_value(count) OVER()::numeric) AS conv_rate
FROM ridefunnel

--prepare aggregate data for Tableau use
WITH d AS (
          SELECT platform, age_range, COUNT(DISTINCT app_download_key) AS numb_downloads, null
          FROM app_downloads
          LEFT JOIN signups
          ON app_download_key = session_id
          GROUP BY 1, 2),
     s AS (
          SELECT platform, age_range, COUNT(DISTINCT user_id) AS numb_signups, null
          FROM signups
          JOIN app_downloads
          ON app_download_key = session_id
          GROUP BY 1, 2),
     r AS (
          SELECT platform, age_range, COUNT(DISTINCT user_id) AS numb_user_requests, COUNT(DISTINCT ride_id) AS numb_ride_requests 
          FROM ride_requests
          JOIN signups
          USING(user_id)
          JOIN app_downloads
          ON app_download_key = session_id
          GROUP BY 1, 2),
     a AS (
          SELECT platform, age_range, COUNT(DISTINCT user_id) AS numb_user_accept, COUNT(DISTINCT ride_id) AS numb_ride_accept 
          FROM ride_requests
          JOIN signups
          USING(user_id)
          JOIN app_downloads
          ON app_download_key = session_id
          WHERE accept_ts IS NOT NULL
          GROUP BY 1, 2),
     P AS (
          SELECT platform, age_range, COUNT(DISTINCT user_id) AS numb_user_pickups, COUNT(DISTINCT ride_id) AS numb_ride_pickups
          FROM ride_requests
          JOIN signups
          USING(user_id)
          JOIN app_downloads
          ON app_download_key = session_id
          WHERE pickup_ts IS NOT NULL
          GROUP BY 1, 2),
     t AS (
          SELECT platform, age_range, COUNT(DISTINCT user_id) AS numb_user_transactions, COUNT(DISTINCT ride_id) AS numb_ride_transactions
          FROM transactions
          JOIN ride_requests
          USING(ride_id)
          JOIN signups
          USING(user_id)
          JOIN app_downloads
          ON app_download_key = session_id
          WHERE charge_status = 'Approved'
          GROUP BY 1, 2),
     rv AS (
          SELECT platform, age_range, COUNT(DISTINCT user_id) AS numb_user_reviews, COUNT(DISTINCT ride_id) AS numb_ride_reviews
          FROM reviews
          JOIN signups
          USING(user_id)
          JOIN app_downloads
          ON app_download_key = session_id 
          GROUP BY 1, 2)
SELECT 0 AS step, 'downloads' AS stage, platform, age_range, numb_downloads AS user_count, NULL::numeric AS ride_count
FROM d
UNION
SELECT 1, 'signups', platform, age_range, numb_signups, NULL
FROM s
UNION
SELECT 2, 'requests', platform, age_range, numb_user_requests, numb_ride_requests
FROM r
UNION
SELECT 3, 'accepted rides', platform, age_range, numb_user_accept, numb_ride_accept
FROM a
UNION
SELECT 4, 'completed rides', platform, age_range, numb_user_pickups, numb_ride_pickups
FROM p
UNION
SELECT 5, 'approved transactions', platform, age_range, numb_user_transactions, numb_ride_transactions
FROM t
UNION
SELECT 6, 'reviews', platform, age_range, numb_user_reviews, numb_ride_reviews
FROM rv
ORDER BY step

--Avg wait time
SELECT AVG(accept_ts - request_ts)
FROM ride_requests

--users who cancel once never complete a single ride
SELECT COUNT(pickup_ts)
FROM (
     SELECT DISTINCT(user_id)
     FROM ride_requests
     WHERE cancel_ts IS NOT NULL) AS t1
JOIN ride_requests
USING (user_id)

--acceptance rate is constant over time for users who don't complete their rides, wait time remains consistently high
WITH t1 AS (
            SELECT user_id, 
                   NTILE(4) OVER (PARTITION BY user_id ORDER BY request_ts) AS quartile,
                   request_ts, 
                   accept_ts, 
                   cancel_ts
            FROM ride_requests
            WHERE pickup_ts IS NULL)
SELECT quartile, COUNT(accept_ts)/COUNT(quartile)::numeric AS accept_rate,
       AVG(accept_ts - request_ts) AS wait_time
FROM t1
GROUP BY 1
ORDER BY 1

--data for machine learning classification
SELECT user_id, platform, age_range, 
       EXTRACT(EPOCH FROM signup_ts-download_ts) AS time_to_signup,
       EXTRACT(EPOCH FROM(MIN(request_ts)-signup_ts)) AS time_to_first_request,
       EXTRACT(EPOCH FROM(AVG(accept_ts-request_ts))) AS mean_wait_time,
       AVG(CASE WHEN accept_ts IS NULL THEN 0 ELSE 1 END) as acceptance_rate,
       MIN(CASE WHEN cancel_ts IS NULL THEN 0 else 1 END) as churned
FROM ride_requests
JOIN signups
USING (user_id)
JOIN app_downloads
ON session_id=app_download_key
GROUP BY user_id, platform, age_range, signup_ts, download_ts

