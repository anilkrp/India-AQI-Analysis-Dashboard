-- 1. Total records in the dataset
SELECT COUNT(*) AS total_rows FROM aqi_data;

-- 2. View the first 50 rows to understand data structure
SELECT * FROM aqi_data LIMIT 50;

-- 3. List all unique states monitored in this dataset
SELECT DISTINCT state FROM aqi_data ORDER BY state;

-- 4. Count how many unique cities/areas are present
SELECT COUNT(DISTINCT area) AS unique_areas FROM aqi_data;

-- 5. Find the highest and lowest AQI values ever recorded
SELECT MAX(aqi_value) as max_aqi, MIN(aqi_value) as min_aqi FROM aqi_data;

-- 6. List all records where air quality was 'Severe'
SELECT * FROM aqi_data WHERE air_quality_status = 'Severe';

-- 7. Count how many monitoring stations each state has (Total Capacity)
SELECT state, SUM(number_of_monitoring_stations) as total_stations 
FROM aqi_data GROUP BY state;

-- 8. Find the average AQI value across the entire country
SELECT AVG(aqi_value) as national_average FROM aqi_data;

-- 9. Filter records for a specific date (e.g., New Year's Day)
SELECT * FROM aqi_data WHERE date = '2024-01-01';

-- 10. List the unique types of pollutants tracked
SELECT DISTINCT pollutant_individual FROM aqi_data WHERE pollutant_individual IS NOT NULL;

-- 11. Find the top 10 most polluted entries currently in the table
SELECT area, state, aqi_value FROM aqi_data ORDER BY aqi_value DESC LIMIT 10;

-- 12. Count records for each air quality status (Good, Satisfactory, etc.)
SELECT air_quality_status, COUNT(*) as frequency FROM aqi_data GROUP BY air_quality_status;

-- 13. Ranking states by their average AQI (Highest to Lowest)
SELECT state, AVG(aqi_value) as avg_aqi FROM aqi_data 
GROUP BY state ORDER BY avg_aqi DESC;

-- 14. Monthly pollution trends (Average AQI per Month)
SELECT month_name, AVG(aqi_value) as monthly_avg 
FROM aqi_data GROUP BY month_name ORDER BY monthly_avg DESC;

-- 15. Identify which pollutant is the most frequent "Prominent Pollutant"
SELECT pollutant_individual, COUNT(*) as occurrence 
FROM aqi_data GROUP BY pollutant_individual ORDER BY occurrence DESC;

-- 16. Compare pollution levels on Weekdays vs Weekends
SELECT day_type, AVG(aqi_value) as avg_aqi FROM aqi_data GROUP BY day_type;

-- 17. Find areas where the average AQI is higher than 200 (Poor/Severe Zones)
SELECT area, state, AVG(aqi_value) as avg_aqi 
FROM aqi_data GROUP BY area, state HAVING AVG(aqi_value) > 200;

-- 18. Count 'Severe' air quality days per state
SELECT state, COUNT(*) as severe_days 
FROM aqi_data WHERE air_quality_status = 'Severe' GROUP BY state ORDER BY severe_days DESC;

-- 19. Find the average AQI for each season (Winter vs Summer vs Monsoon)
SELECT season, AVG(aqi_value) as seasonal_avg FROM aqi_data GROUP BY season;

-- 20. Areas with the highest number of monitoring stations
SELECT area, state, number_of_monitoring_stations 
FROM aqi_data WHERE number_of_monitoring_stations > 5 ORDER BY number_of_monitoring_stations DESC;

-- 21. Distribution of pollutants in 'Good' air quality conditions
SELECT pollutant_individual, COUNT(*) 
FROM aqi_data WHERE air_quality_status = 'Good' GROUP BY pollutant_individual;

-- 22. Find states where AQI has ever hit the maximum limit of 500
SELECT DISTINCT state FROM aqi_data WHERE aqi_value = 500;

-- 23. Average AQI per year to see if pollution is increasing
SELECT year, AVG(aqi_value) as yearly_avg FROM aqi_data GROUP BY year;

-- 24. Find cities that have only 1 monitoring station but report 'Severe' air
SELECT DISTINCT area, state FROM aqi_data 
WHERE number_of_monitoring_stations = 1 AND air_quality_status = 'Severe';

-- 25. Calculate the percentage of 'Satisfactory' or 'Good' days in Delhi
SELECT (COUNT(CASE WHEN air_quality_status IN ('Good', 'Satisfactory') THEN 1 END) * 100.0 / COUNT(*)) as healthy_day_percentage
FROM aqi_data WHERE state = 'Delhi';

-- 26. Rank cities within each state based on average AQI (Partitioning)
SELECT state, area, AVG(aqi_value) as avg_aqi,
RANK() OVER(PARTITION BY state ORDER BY AVG(aqi_value) DESC) as pollution_rank
FROM aqi_data GROUP BY state, area;

-- 27. Calculate a 7-day Moving Average for AQI in a specific city
SELECT date, aqi_value,
AVG(aqi_value) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_avg
FROM aqi_data WHERE area = 'Delhi';

-- 28. Identify "Hotspots": Areas where AQI is 50% higher than their State Average
WITH StateAverages AS (
    SELECT state, AVG(aqi_value) as state_avg FROM aqi_data GROUP BY state
)
SELECT a.area, a.state, a.aqi_value, s.state_avg
FROM aqi_data a JOIN StateAverages s ON a.state = s.state
WHERE a.aqi_value > (s.state_avg * 1.5);

-- 29. Find the "Pollution Spike" (Date where the national average was at its peak)
SELECT date, AVG(aqi_value) as daily_nat_avg 
FROM aqi_data GROUP BY date ORDER BY daily_nat_avg DESC LIMIT 1;

-- 30. Calculate Month-over-Month (MoM) change in AQI for Mumbai
WITH MumbaiMonthly AS (
    SELECT month_name, AVG(aqi_value) as avg_aqi, year
    FROM aqi_data WHERE area = 'Mumbai' GROUP BY month_name, year
)
SELECT month_name, avg_aqi, 
LAG(avg_aqi) OVER(ORDER BY year, month_name) as prev_month_aqi
FROM MumbaiMonthly;

-- 31. Find the state with the most volatile air quality (Highest Standard Deviation)
SELECT state, STDDEV(aqi_value) as aqi_volatility 
FROM aqi_data GROUP BY state ORDER BY aqi_volatility DESC;

-- 32. Identify days where AQI improved by more than 50 points compared to the previous day
SELECT area, date, aqi_value, 
LAG(aqi_value) OVER(PARTITION BY area ORDER BY date) as prev_day_aqi
FROM aqi_data 
WHERE (prev_day_aqi - aqi_value) > 50;

-- 33. Categorize states by 'Environmental Risk' based on their median AQI
SELECT state, 
CASE 
    WHEN AVG(aqi_value) < 100 THEN 'Low Risk'
    WHEN AVG(aqi_value) BETWEEN 100 AND 200 THEN 'Moderate Risk'
    ELSE 'High Risk'
END as risk_category
FROM aqi_data GROUP BY state;

-- 34. Find the most common pollutant responsible for 'Severe' status in each state
WITH PollutantCounts AS (
    SELECT state, pollutant_individual, COUNT(*) as cnt,
    RANK() OVER(PARTITION BY state ORDER BY COUNT(*) DESC) as rnk
    FROM aqi_data WHERE air_quality_status = 'Severe' GROUP BY state, pollutant_individual
)
SELECT state, pollutant_individual FROM PollutantCounts WHERE rnk = 1;

-- 35. Cumulative count of 'Poor' or worse days per state over time
SELECT state, date, 
COUNT(*) OVER(PARTITION BY state ORDER BY date) as cumulative_bad_days
FROM aqi_data WHERE aqi_value > 200;

-- 36. Compare the average AQI of top 5 most polluted vs bottom 5 most polluted states
(SELECT 'Most Polluted' as type, state, AVG(aqi_value) as aqi FROM aqi_data GROUP BY state ORDER BY aqi DESC LIMIT 5)
UNION ALL
(SELECT 'Least Polluted' as type, state, AVG(aqi_value) as aqi FROM aqi_data GROUP BY state ORDER BY aqi ASC LIMIT 5);

-- 37. Find areas that have never recorded a 'Good' air quality day
SELECT DISTINCT area, state FROM aqi_data 
WHERE area NOT IN (SELECT area FROM aqi_data WHERE air_quality_status = 'Good');

-- 38. Calculate the average AQI per monitoring station count (Correlation check)
SELECT number_of_monitoring_stations, AVG(aqi_value) as avg_reported_aqi 
FROM aqi_data GROUP BY number_of_monitoring_stations ORDER BY number_of_monitoring_stations;

-- 39. Identify the "Pollution Capital" (Area with highest avg AQI) for every year
WITH AnnualRanks AS (
    SELECT year, area, AVG(aqi_value) as avg_aqi,
    RANK() OVER(PARTITION BY year ORDER BY AVG(aqi_value) DESC) as rnk
    FROM aqi_data GROUP BY year, area
)
SELECT year, area, avg_aqi FROM AnnualRanks WHERE rnk = 1;

-- 40. Percentage contribution of PM2.5 to total pollution records vs other pollutants
SELECT pollutant_individual, 
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM aqi_data), 2) as pct_contribution
FROM aqi_data GROUP BY pollutant_individual;