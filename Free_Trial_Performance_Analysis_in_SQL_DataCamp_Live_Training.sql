-- Free Trial Performance Analysis in SQL 
-- Live guided exercise on datacamp
-- Read me file contains project objective and schema 
-- Link to live training: https://datacamp-1.wistia.com/medias/g0w1uz6hbr
-- Link to datacamp hosted file: https://app.datacamp.com/workspace/w/cf4bf2a8-6511-4712-b848-16ed311d7554
-- NOTE: Exercise 1c) Create a line graph of num_purchases by month does NOT load on public workspace - internal error.
-- NOTE: Initialy started live training on Datacamps internal IDE then switched to DbVisualizer to gain more experience using an IDE that an analyst would be using on the job.

-- Data Access
-- To access the data, create a PostgreSQL integration with the following details:
-- host: workspacedemodb.datacamp.com
-- port: 5432
-- database: free_trial_performance
-- username: competition_free_trial
-- password: workspace


/*
How much is a free trial worth? In this SQL live training, you'll learn how to use SQL to analyze marketing data for a free trial of a product. 
You’ll summarize and aggregate data to calculate the sorts of metrics that are the bread and butter of any marketing analyst role.
*/

-- 1. Getting Familiar with the Data --
-- We will query the Free Trials & Purchases tables, and produce graphs showing the volume of both of these over time.
-- 1a) Group trials by the month of free_trial_start_date (and order by the same).Count the rows as num_free_trials.

SELECT
	date_trunc('month', free_trial_start_date) AS month,
	COUNT(*) AS num_free_trials
FROM trials
	GROUP BY month
	ORDER BY month;



-- 1b) Group purchases by the month of purchase_date (and order by the same).
-- Count the rows as num_purchases, and sum purchase_value as usd_value.
--Call the output purchases_per_month. 

SELECT
	date_trunc('month', purchase_date) AS month,
	COUNT(*) AS purchases_per_month,
	sum(purchase_value) AS usd_value
FROM purchases
	GROUP BY month
	ORDER BY month;



-- 2. Data Aggregation 1 - Velocity Metrics by Month
-- We will pull metrics for Free Trial Starts, Purchases, and Gross Merchandise Value by month from the Free Trials & Purchases tables.
-- 2a) Now that we can aggregate the data by month, create both summaries as Common Table Expressions (CTEs), and left join our purchases per month 
-- against the free trials per month to get the results into a combined results table.


WITH free_trials_per_month AS (
        SELECT
                date_trunc('month', free_trial_start_date) AS month,
                COUNT(*) AS num_free_trials
        FROM trials
                GROUP BY month
                ORDER BY month
),
        purchases_per_month AS (
        SELECT
                date_trunc('month', purchase_date) AS month,
                COUNT(*) AS num_purchases,
                sum(purchase_value) AS usd_value
        FROM purchases
                GROUP BY month
                ORDER BY month
)

SELECT
        free_trials_per_month.month,
        free_trials_per_month.num_free_trials,
        purchases_per_month.num_purchases,
        purchases_per_month.usd_value
FROM free_trials_per_month
        LEFT JOIN purchases_per_month
        ON purchases_per_month.month = free_trials_per_month.month;


-- Do you notice that there's some data missing? When we left join purchases_per_month, we only match against months that exist in free_trials_per_month. 
-- There are several ways to solve this.
-- 2b) Do the same aggregation again, but this time outer join the results.

WITH free_trials_per_month AS (
        SELECT
                date_trunc('month', free_trial_start_date) AS month,
                COUNT(*) AS num_free_trials
        FROM trials
                GROUP BY month
                ORDER BY month
),
        purchases_per_month AS (
        SELECT
                date_trunc('month', purchase_date) AS month,
                COUNT(*) AS num_purchases,
                sum(purchase_value) AS usd_value
        FROM purchases
                GROUP BY month
                ORDER BY month
)

SELECT
        free_trials_per_month.month,
        free_trials_per_month.num_free_trials,
        purchases_per_month.num_purchases,
        purchases_per_month.usd_value
FROM free_trials_per_month
        FULL OUTER JOIN purchases_per_month
        ON purchases_per_month.month = free_trials_per_month.month;
   
 
        
-- Using coalesce
WITH free_trials_per_month AS (
        SELECT
                date_trunc('month', free_trial_start_date) AS month,
                COUNT(*) AS num_free_trials
        FROM trials
                GROUP BY month
                ORDER BY month
),
        purchases_per_month AS (
        SELECT
                date_trunc('month', purchase_date) AS month,
                COUNT(*) AS num_purchases,
                sum(purchase_value) AS usd_value
        FROM purchases
                GROUP BY month
                ORDER BY month
)

SELECT
        COALESCE(free_trials_per_month.month, purchases_per_month.month) AS month,
        free_trials_per_month.num_free_trials,
        purchases_per_month.num_purchases,
        purchases_per_month.usd_value
FROM free_trials_per_month
        FULL OUTER JOIN purchases_per_month
        ON purchases_per_month.month = free_trials_per_month.month; 


-- Gaps in your summary data is a common problem when using SQL for data analysis. It happens when you have data sets that don't quite match up, or gaps in your time frame.
-- Another way to solve this would be to avoid joining the tables directly to one another, and instead join both tables to a base table that contains all the rows you 
-- need - usually something like a dates table.

-- 3. Data Aggregation 2 - Cohort Metrics by Month
-- We will discuss the differences between Velocity & Cohort Metrics, and then join the tables in order to pull the equivalent Cohort Metrics by Month.
/*

In our answer to Question 2, we showed counts of Purchases & Free trials by month without regard for the fact that those purchases will all correspond to free trials for the previous month. 
This means that the num_purchases and usd_value metrics we calculated were what's sometimes called 'velocity' or 'naïve' metrics; they represent a simple comparison of other metrics in a time period. 
This is why we have no Purchases data for the first month and no Free Trials data for the last month.

Velocity metrics are easy to calculate, and they are great for regular trading meetings because they don't change retrospectively. 
The number of sales we had yesterday is a fixed quantity, whereas the free trials that were started yesterday haven't had time to turn into sales yet. 
However, they aren't always the clearest way of looking at the data - in the above it looks like we had a terrible January.

Alternatively, we can join each purchase against its corresponding Free Trial and look at it all by Free Trial Start Date. 
This allows us to look at the conversion rate of group of people who all started their free trials at the same time, called a cohort. 
That means we compare January's performance vs. the other months.

Cohort metrics are a fairer comparison, especially when there are aspects that are particular to a time-based cohort (such as a temporarily reduced price for a sale). 
However, they take time to mature. You don't always want to spend today's trading looking an entire month back in time.
*/


-- 3a) Select all columns in trials, and left join the columns in purchases on their shared trial_id column.

SELECT 
        trials.trial_id, 
        trials.free_trial_start_date,
        trials.region,
        purchases.purchase_date,
        purchase_value
FROM trials
        LEFT JOIN purchases
                ON purchases.trial_id = trials.trial_id;


-- Do you notice that there's some data missing? When we left join purchases_per_month, we only match against months that exist in free_trials_per_month. 
-- There are several ways to solve this.


--3b) Aggregate all the data by the month of the Free Trial start, and calculate the same metrics as before; num_free_trials, num_purchases, and usd_value. 
-- Remember that sum and count both ignore NULL values.

WITH free_trials_and_purchases AS (
        SELECT
                trials.trial_id,
                trials.free_trial_start_date,
                trials.region,
                purchases.purchase_date,
                purchase_value
        FROM trials
                LEFT JOIN purchases
                        ON purchases.trial_id = trials.trial_id
)

SELECT
        date_trunc('month', free_trial_start_date) AS month,
        COUNT(*) AS num_free_trials,
        COUNT(purchase_date) AS num_purchases,
        SUM(purchase_value) AS usd_value
FROM free_trials_and_purchases
        GROUP BY month
        ORDER BY month


/*
Counting the non-nulls is very handy, but you should be careful with this kind of approach as different versions of SQL may handle NULL values differently. 
You also have to be confident that the column you are counting over is populated in every case you want to count - or in other words that there is a date 
for every purchase (and no purchase date when there is no purchase).
*/



-- 4. Free Trial Value Calculation
-- Using the Cohort table we've already put together, we will calculate an average value per Free Trial for each month.

-- 4a) Take the aggregation above, and create an additional metric called cohort_value_per_free_trial by dividing purchase_value by num_free_trials.

WITH  free_trials_and_purchases AS (
	SELECT
                trials.trial_id,
                trials.free_trial_start_date,
                trials.region,
                purchases.purchase_date,
                purchases.purchase_value
    FROM trials
        LEFT JOIN purchases
            ON purchases.trial_id = trials.trial_id
)

SELECT
	date_trunc('month', free_trial_start_date) AS MONTH,
    	COUNT(*) AS num_free_trials,
    	COUNT(purchase_date) AS num_purchases,
    	SUM(purchase_value) AS usd_value
FROM free_trials_and_purchases
        GROUP BY month
        ORDER BY month;


-- 5. Dimensional Breakdown
-- We will break down our average value per Free Trial by Region, to see how the values differ.

-- a) Taking the same code as before, introduce and group by the additional dimension, region. Call the resultant table cohort_value_by_month_and_region.

WITH free_trials_and_purchases AS (
	SELECT
                trials.trial_id,
        	trials.free_trial_start_date,
        	trials.region,
        	purchases.purchase_date,
        	purchases.purchase_value
    FROM trials
        LEFT JOIN purchases
            ON purchases.trial_id = trials.trial_id
)

,	summary_by_month AS (
    SELECT
                date_trunc('month', free_trial_start_date) AS MONTH,
                region,
        	COUNT(*) AS num_free_trials,
        	COUNT(purchase_date) AS num_purchases,
        	SUM(purchase_value) AS usd_value
    FROM free_trials_and_purchases
            GROUP BY month, region
)

SELECT
        month,
        region,
        num_free_trials,
        num_purchases,
        usd_value,
        (usd_value::float) / (nullif(num_free_trials, 0)::float) AS cohort_value_per_free_trial
FROM summary_by_month
        ORDER BY month, region;
        
     
        
        
          
                
























