Project Title: Cyclistic Bike-Share Ride Analysis
Overview:
This project analyzes ride usage patterns from Cyclistic’s bike-share service using SQL. Monthly data from January to April was processed in SQL Workbench to investigate trends in ride durations, user behavior by membership type, and weekly engagement patterns. The goal was to derive insights that can support user segmentation, marketing strategies, and service optimization.
Objectives:
•	Clean and prepare ride data across multiple months.
•	Merge monthly datasets into a single unified view for consistent analysis.
•	Analyze ride length patterns and usage distribution by membership status and day of the week.
•	Identify behavioral differences between casual riders and members.
Key Steps:
1.	Data Cleaning & Standardization:
o	Unified column types (e.g., ride_length and ended_at) across January to April tables.
o	Created a view (merge_table) combining all monthly datasets for centralized querying.
2.	Exploratory Analysis:
o	Calculated maximum and minimum ride lengths for each month.
o	Assessed ride duration by membership type (casual vs. member).
o	Analyzed usage patterns across weekdays to identify high- and low-engagement days for both groups.
3.	Segment-Based Insights:
o	Determined which membership group had longer ride durations.
o	Compared day-of-week usage trends between members and casual riders.
o	Identified ride IDs associated uniquely with either group for deeper segmentation.
Insights:
•	Ride Duration Differences: Members tend to have more consistent, shorter rides, while casual users often engage in longer, irregular trips.
•	Peak Usage Days: Casual riders showed higher activity during weekends, while members were more active during weekdays, possibly commuting.
•	Strategic Implications: These behavioral patterns can inform tailored promotions, membership incentives, and scheduling of bike availability based on expected demand.
Tools Used:
•	SQL Workbench
•	MySQL syntax for querying, cleaning, and aggregation.

