CREATE DATABASE Business_marketing;
USE Business_marketing;
--  1. What is the total revenue of the company this year?
--  2. What is the total peformance YOY?
--  3. What is the MoM revenue performance?
--  4. What is the total revenue vs target performance for the year?
--  5. What is the total revenue vs target performance for the month?
--  6. What is the best performing product in terms of revenue this year?
--  7. What is the product performancde Vs Target for the month?
--  8. Which is account is performing the best in terms of revenue?
--  9. Which account is performing best in terms of revenue Vs target?
--  10. Which account is performing worst in terms of meeting target for the year?
--  11. Which opportuinty has the highest potential and what are the details?
--  12. Which account guarantee the most revenue per marketing spirit for this month? 



IF OBJECT_ID ('targets_raw_data') IS NOT NULL DROP targets_raw_data

	CREATE TABLE targets_raw_data (
	Account_No INT,
	Month_ID INT,
	Product_Category VARCHAR (20),
	Target FLOAT 
	);
    
BULK INSERT targets_raw_data
FROM ''
WITH ( FORMAT = CSV);

SELECT * FROM business_marketing.`revenue raw data`;
DESCRIBE business_marketing.`revenue raw data`;
DESCRIBE business_marketing.`targets raw data`;

SELECT * FROM business_marketing.`marketing_raw_data`;
SELECT * FROM business_marketing.`targets_raw_data`;
SELECT * FROM business_marketing.`yt_account_lookup`;
SELECT * FROM business_marketing.`yt_calendar_lookup`;
SELECT * FROM business_marketing.`yt_opportunities_data`;
 

CREATE TABLE revenue_raw_data (
Account_No INT,
Month_ID INT,
Product_Category VARCHAR (20),
Revenue INT 
);

CREATE TABLE targets_raw_data (
Account_No INT,
Month_ID INT,
Product_Category VARCHAR (20),
Target FLOAT 
);


CREATE TABLE marketing_raw_data(
Account_No INT,
Month_ID INT,
Product_Category VARCHAR (20),
Marketing_Spend INT );


CREATE TABLE yt_account_lookup (
 New_Account_No NVARCHAR (50),
 New_Account_Name NVARCHAR (50),
 Industry NVARCHAR (50),
 Sector NVARCHAR (50),
 Account_Segment NVARCHAR (50),
 Account_Manager_Alias NVARCHAR (50),
 Segment_Manager NVARCHAR (50),
 Industry_Manager NVARCHAR (50)
 );


CREATE TABLE yt_calendar_lookup (
Date DATE,
Day_Name TEXT,
Day_No INT,
Week_ID INT,
Week_No INT,
Month_No INT,
Year_No INT,
Quarter_No INT,
Quarter_ID INT,
Month_ID INT,
Week_Date DATE,
Month_Name TEXT,
Fiscal_Month NVARCHAR (20),
Fiscal_Quarter NVARCHAR (20),
Fiscal_Year NVARCHAR (20)
 );
 
CREATE TABLE yt_opportunities_data (
New_Account_No INT,
Opportunity_ID NVARCHAR (20),
New_Opportunity_Name NVARCHAR (20),
Est_Completion_Month_ID INT,
Product_Category TEXT,
Opportunity_Stage NVARCHAR (20),
Est_Opportunity_Value INT
 );

--  1. What is the total revenue of the company this year?
SELECT #Month_ID, 
SUM(Revenue) AS Total_Revenue FROM revenue_raw_data
WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM business_marketing.yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
#GROUP BY Month_ID

--  2. What is the total peformance YOY?
SELECT a.Total_Revenue_fy21, b.Total_Revenue_fy20, a.Total_Revenue_fy21 - b.Total_Revenue_fy20 AS Dollar_Diff_YOY, a.Total_Revenue_fy21 / b.Total_Revenue_fy20 - 1 AS Perc_Diff_YOY
FROM
(
	SELECT #Month_ID,
    SUM(Revenue) AS Total_Revenue_fy21 FROM revenue_raw_data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM business_marketing.yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
	#GROUP BY Month_ID
	) a,
    
(
    SELECT #Month_ID,
    SUM(Revenue) AS Total_Revenue_fy20 FROM revenue_raw_data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID - 12 FROM revenue_raw_data 
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM business_marketing.yt_calendar_lookup WHERE `Fiscal Year` = "FY21"))
    #GROUP BY Month_ID
	) b

--  3. What is the MoM revenue performance?
SELECT 	a.Total_Revenue_TM, b.Total_Revenue_LM, a.Total_Revenue_TM - b.Total_Revenue_LM AS Dollar_Diff_MOM, a.Total_Revenue_TM / b.Total_Revenue_LM - 1 AS Perc_Diff_MOM
FROM
    ( #This Month
	SELECT #Month_ID,
	SUM(Revenue) AS Total_Revenue_TM FROM revenue_raw_data
	WHERE Month_ID IN (SELECT MAX(Month_ID) FROM revenue_raw_data)
	#GROUP BY Month_ID)
	) a,

	( #Last Month
	SELECT #Month_ID,
	SUM(Revenue) AS Total_Revenue_LM FROM revenue_raw_data
	WHERE Month_ID IN (SELECT MAX(Month_ID) - 1 FROM revenue_raw_data)
	#GROUP BY Month_ID
	) b    
    
--  4. What is the total revenue vs target performance for the year?
SELECT a.Total_Revenue_fy21, b.Total_target_fy21, a.Total_Revenue_fy21 - b.Total_target_fy21 AS Dollar_Diff_YOY, a.Total_Revenue_fy21 / b.Total_target_fy21 - 1 AS Perc_Diff_YOY 
FROM
	(
	SELECT #Month_ID,
	SUM(Revenue) AS Total_Revenue_fy21 FROM revenue_raw_data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM business_marketing.yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
	#GROUP BY Month_ID
	) a,
	
	(
	SELECT #Month_ID,
	SUM(Target) AS Total_target_fy21 FROM targets_raw_data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM revenue_raw_data 
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM business_marketing.yt_calendar_lookup WHERE `Fiscal Year` = "FY21"))
	#GROUP BY Month_ID
	) b
    

--  5. What is the total revenue vs target performance for the month?
SELECT a.Month_ID, `Fiscal Month`, Total_Revenue_fy21, Total_target_fy21, Total_Revenue_fy21 - Total_target_fy21 AS Dollar_Diff_YOY, Total_Revenue_fy21 / Total_target_fy21 - 1 AS Perc_Diff_YOY 
FROM
(
	SELECT Month_ID,
	SUM(Revenue) AS Total_Revenue_fy21 FROM revenue_raw_data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM business_marketing.yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
	GROUP BY Month_ID
	) a
	LEFT JOIN
	(
	SELECT Month_ID,
	SUM(Target) AS Total_target_fy21 FROM targets_raw_data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM revenue_raw_data 
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM business_marketing.yt_calendar_lookup WHERE `Fiscal Year` = "FY21"))
	GROUP BY Month_ID
	) b
    ON a.Month_ID = b.Month_ID
    #But if you want to see the fiscal month along side the month ID then we do anther left on the calender table
    LEFT JOIN
    (SELECT DISTINCT Month_ID, `Fiscal Month` FROM business_marketing.yt_calendar_lookup) c
    ON a.Month_ID = c.Month_ID
ORDER BY Month_ID
    
--  6. What is the best performing product in terms of revenue this year? Fy21
SELECT Product_Category, SUM(Revenue) AS Total_Revenue_Fy21 FROM revenue_raw_data
WHERE MOnth_ID IN (SELECT DISTINCT Month_ID FROM business_marketing.yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
GROUP BY Product_Category
ORDER BY Revenue DESC

--  7. What is the product performance Vs Target for the month?
SELECT a.Month_ID, a.Product_Category, Total_Revenue, Total_Target, Total_Revenue / Total_Target - 1 AS Rev_vs_Target
FROM
	(
	SELECT Month_ID, Product_Category, SUM(Revenue) AS Total_Revenue FROM revenue_raw_data
	WHERE Month_ID IN (SELECT MAX(Month_ID) FROM revenue_raw_data)
	GROUP BY Month_ID, Product_Category
	) a
    
	LEFT JOIN
	(
	SELECT Month_ID, Product_Category, SUM(Target) AS Total_Target FROM targets_raw_data
	WHERE Month_ID IN (SELECT MAX(Month_ID) FROM revenue_raw_data)
	GROUP BY Month_ID, Product_Category
	) b
	ON a.Month_ID = b.Month_ID AND a.Product_Category = b.Product_Category

--  8. Which is account is performing the best in terms of revenue?
SELECT a.Account_No, New_Account_Name, Revenue
FROM
	(
	SELECT Account_No, SUM(Revenue) AS Revenue FROM revenue_raw_data
	GROUP BY Account_No
	) a
	LEFT JOIN
	(SELECT * FROM yt_account_lookup) b
	ON a.Account_No = b.New_Account_No

ORDER BY Revenue DESC

--  9. Which account is performing best in terms of revenue Vs target? Fy21

SELECT a.Account_No, New_Account_No, Revenue, Target, Revenue / NULLIF(Target,0) -1 AS Rev_vs_Target
FROM  
	(SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No, Revenue, Target
	FROM
		(
		SELECT Account_No, SUM(Revenue) AS Revenue FROM revenue_raw_data
		WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
		GROUP BY Account_No
		) a
		
		FULL JOIN 
		(	
		SELECT Account_No, SUM(Target) AS Target FROM targets_raw_data
		WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM yt_calendar_lookup WHERE `Fiscal Year`= "FY21")
		GROUP BY Account_No
		) b
		ON a.Account_No = b.Account_No
		) a
		(SELECT * FROM yt_calendar_lookup) b
		ON a.Account_No = b.New_Account_No

ORDER BY Revenue / NULLIF(Target,0) -1 DESC

--  10. Which account is performing worst in terms of meeting target for the year?

SELECT a.Account_No, New_Account_No, Revenue, Target, ISNULL(Revenue,0) / NULLIF(ISNULL(Target,0),0) -1 AS Rev_vs_Target
FROM  
	(SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No, Revenue, Target
	FROM
		(
		SELECT Account_No, SUM(Revenue) AS Revenue FROM revenue_raw_data
		WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
		GROUP BY Account_No
		) a
		
		FULL JOIN 
		(	
		SELECT Account_No, SUM(Target) AS Target FROM targets_raw_data
		WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM yt_calendar_lookup WHERE `Fiscal Year`= "FY21")
		GROUP BY Account_No
		) b
		ON a.Account_No = b.Account_No
		) a
		(SELECT * FROM yt_calendar_lookup) b
		ON a.Account_No = b.New_Account_No

ORDER BY Revenue / NULLIF(Target,0) -1 

--  11. Which opportuinty has the highest potential and what are the details? FY21

SELECT * FROM yt_opportunities_data
WHERE `Est Completion Month ID` IN (SELECT DISTINCT Month_ID FROM yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
GROUP BY `New Opportunity Name`
LIMIT 1

--  12. Which account guarantee the most revenue per marketing spirit for this month?  
SELECT ISNULL(a.ACCOUNT_No,b.Account_No) AS Account_No, Revenue, Marketing_Spend, ISNULL(Revenue,0) / NULLIF(ISNULL(Marketing_Spend,0),0) AS Rev_per_Spend
FROM
	(
	SELECT Account_No, SUM(Revenue) AS Revenue FROM revenue_raw_data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
	GROUP BY Account_No
	) a
			
	FULL JOIN
	(
	SELECT Account_No, SUM(Marketing_Spend) AS Marketing_Spend FROM marketing_raw_data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM yt_calendar_lookup WHERE `Fiscal Year` = "FY21")
	GROUP BY Account_No        
	) b
	ON a.Account_No = b.Account_No