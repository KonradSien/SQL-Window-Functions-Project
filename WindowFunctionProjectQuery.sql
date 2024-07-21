-- WINDOW FUNCTIONS

--Average price with OVER

SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	AVG(price) OVER() AS avg_price	
FROM bookings;

--Difference from average price with OVER

SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	price,
	ROUND(AVG(price) OVER(), 2) AS avg_price,
	ROUND((price - AVG(price)) OVER(), 2) AS diff_from_avg_price
FROM bookings;

--Percent of average price with OVER

SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	price,
	ROUND(AVG(price) OVER(), 2) AS avg_price,
	ROUND((price / AVG(price)) OVER() *100 , 2) AS percent_of_avg_price
FROM bookings;


-- Percent difference from average price

SELECT 
	booking_id,
	listing_name,
	neighbourhood_group,
	price,
	ROUND(AVG(price) OVER(), 2) AS avg_price,
	ROUND((price / AVG(price) OVER() -1)*100, 2) AS percent_diff_from_avg_price
FROM bookings;


----------------------------------------------------------------------------------------------------------------
-- PARTITION BY 

-- PARTITION BY neighbourhood group
SELECT	
	booking_id,
	listing_name,
	neighbourhood_group,
	price,
	AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group
FROM bookings;

-- PARTITION BY neighbourhood group, and (neighbourhood group, neighbourhood)

SELECT	
	booking_id,
	listing_name,
	neighbourhood_group,
	price,
	AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group,
	AVG(price) OVER(PARTITION BY neighbourhood_group,neighbourhood) as avg_price_by_group_and_neigh
FROM bookings;	

-- Difference from average neighbourhood group price

SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group,
	ROUND(price - AVG(price) OVER(PARTITION BY neighbourhood_group), 2) AS diff_from_avg_neigh_group_price
FROM bookings;


----------------------------------------------------------------------------------------------------------------
-- ROW_NUMBER

-- overall price rank
SELECT	
	booking_id,
	listing_name,
	neighbourhood_group,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank
FROM bookings;

--neighbourhood group price rank
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank
FROM bookings;

-- Top 3
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
	CASE
		WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC)<=3 THEN 'Yes'
		ELSE 'No'
	END as top3_flag
FROM bookings;

--_________________________________________________________________________________

-- Top 3 with subquery to select only the 'Yes' values in the top3_flag column
SELECT * FROM (
	SELECT
		booking_id,
		listing_name,
		neighbourhood_group,
		neighbourhood,
		price,
		ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
		ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
		CASE
			WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN 'Yes'
			ELSE 'No'
		END AS top3_flag
	FROM bookings)
WHERE top3_flag = 'Yes'

--Top 3 with CTE to select only the 'Yes' values in the top3_flag column
WITH ranked_bookings AS (
    SELECT
        booking_id,
        listing_name,
        neighbourhood_group,
        neighbourhood,
        price,
        ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
        ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
        CASE
            WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN 'Yes'
            ELSE 'No'
        END AS top3_flag
    FROM bookings
)
SELECT *
FROM ranked_bookings
WHERE top3_flag = 'Yes'



--____________________________________________________________________________________
-- RANK AND DENSE_RANK

--ROW_NUMBER VS RANK
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
	RANK() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank_with_rank
FROM bookings;

-- DENSE_RANK
--ROW_NUMBER VS RANK vs DENSE_RANK
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_rank,
	DENSE_RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_dense_rank
FROM bookings;

--____________________________________________________________________________________
-- LAD AND LEAD

-- LAG BY 1 period
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LAG(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- LAG BY 2 periods
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LAG(price, 2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- LEAD by 1 period
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LEAD(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- LEAD by 2 periods
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LEAD(price, 2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;
