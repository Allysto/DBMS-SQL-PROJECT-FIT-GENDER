--1 Based on information requirements of company
SELECT
    -- 1. Total active users
    (SELECT COUNT(*) FROM users WHERE account_status = 'active') AS active_users,
    
    -- 2. Total active subscriptions
    (SELECT COUNT(*) FROM subscriptions WHERE payment_status = 'active') AS active_subscriptions,
    
    -- 3. Average trainer rating
    (SELECT AVG(NVL(average_rating,0)) FROM trainers) AS avg_trainer_rating,
    
    -- 4. Total sessions last month
    (SELECT COUNT(*) FROM sessions 
     WHERE scheduled_date_time BETWEEN ADD_MONTHS(TRUNC(SYSDATE), -1) AND TRUNC(SYSDATE)) AS monthly_sessions,
    
    -- 5. Most popular subscription plan
    (SELECT plan_name FROM (
        SELECT sp.plan_name, COUNT(*) as plan_count
        FROM subscriptions s
        JOIN subscription_plans sp ON s.plan_id = sp.plan_id
        GROUP BY sp.plan_name
        ORDER BY plan_count DESC
    ) WHERE ROWNUM = 1) AS popular_plan,
    
    -- 6. New users this year
    (SELECT COUNT(*) FROM users 
     WHERE registration_date >= TRUNC(SYSDATE, 'YEAR')) AS new_users_this_year,
    
    -- 7. Community posts last month
    (SELECT COUNT(*) FROM community_posts 
     WHERE post_date BETWEEN ADD_MONTHS(TRUNC(SYSDATE), -1) AND TRUNC(SYSDATE)) AS monthly_posts,
    
    -- 8. Total product sales
    (SELECT SUM(total_amount) FROM orders 
     WHERE order_date BETWEEN ADD_MONTHS(TRUNC(SYSDATE), -3) AND TRUNC(SYSDATE)) AS quarterly_sales,
    
    -- 9. Average member tenure (months)
    (SELECT ROUND(AVG(MONTHS_BETWEEN(SYSDATE, registration_date)), 1) 
     FROM users WHERE account_status = 'active') AS avg_member_tenure,
    
    -- 10. Total active trainers
    (SELECT COUNT(*) FROM trainers WHERE is_verified = 1) AS active_trainers
FROM dual;




--2. Limitation of Rows and Columns
-- Get first 5 active users with only essential columns

SELECT user_id, first_name, last_name, email 
FROM users 
WHERE account_status = 'active' 
AND ROWNUM <= 5;

--3. Sorting
-- Users by registration date (newest first)
SELECT user_id, first_name, last_name, registration_date
FROM users
ORDER BY registration_date DESC;

--4. LIKE, AND, OR
-- Find users named John or Jonathan
SELECT user_id, first_name, last_name
FROM users
WHERE first_name LIKE 'John%' OR first_name LIKE 'Jonathan%';


--5. Variables and Character Functions
-- Using variables for dynamic search
DEFINE search_term = 'yoga';
SELECT exercise_id, exercise_name, 
       UPPER(muscle_group_targeted) AS muscle_group,
       LENGTH(description) AS desc_length
FROM exercises
WHERE LOWER(exercise_name) LIKE '%&search_term%';

--6. Round or Trunc
-- Calculate average session duration (rounded)
SELECT trainer_id, 
       ROUND(AVG(duration_minutes), 2) AS avg_duration,
       TRUNC(AVG(duration_minutes)) AS whole_minutes
FROM sessions
WHERE professional_type = 'trainer'
GROUP BY trainer_id;

--7. Date Functions
-- Users who registered in the last 30 days
SELECT user_id, first_name, last_name,
       registration_date,
       ROUND(SYSDATE - CAST(registration_date AS DATE)) AS days_since_registration
FROM users
WHERE registration_date > ADD_MONTHS(SYSTIMESTAMP, -1);

--8. Aggregate Functions
-- Trainer utilization
SELECT t.trainer_id, t.first_name, t.last_name,
       COUNT(s.session_id) AS total_sessions,
       SUM(s.duration_minutes)/60 AS total_hours
FROM trainers t
LEFT JOIN sessions s ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id, t.first_name, t.last_name;

--9. Group By and Having
-- Popular exercise categories
SELECT muscle_group_targeted,
       COUNT(*) AS exercise_count,
       AVG(LENGTH(description)) AS avg_desc_length
FROM exercises
GROUP BY muscle_group_targeted
HAVING COUNT(*) > 3
ORDER BY exercise_count DESC;

--10. Joins
-- Active user subscriptions with plan details
SELECT u.user_id, u.first_name, u.last_name,
       sp.plan_name, s.start_date, s.end_date,
       sp.monthly_price, sp.annual_price
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
JOIN subscription_plans sp ON s.plan_id = sp.plan_id
WHERE s.payment_status = 'active';

--11 Sub-queries
-- Users without any sessions
SELECT user_id, first_name, last_name
FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT user_id
    FROM sessions
);
--extra functionality queries
-- View all group classes
SELECT * FROM group_classes;

-- View all attendance records
SELECT * FROM class_attendance;

