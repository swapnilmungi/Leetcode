/*Table: Actions

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| post_id       | int     |
| action_date   | date    | 
| action        | enum    |
| extra         | varchar |
+---------------+---------+
This table may have duplicate rows.
The action column is an ENUM (category) type of ('view', 'like', 'reaction', 'comment', 'report', 'share').
The extra column has optional information about the action, such as a reason for the report or a type of reaction.
 

Table: Removals

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| post_id       | int     |
| remove_date   | date    | 
+---------------+---------+
post_id is the primary key (column with unique values) of this table.
Each row in this table indicates that some post was removed due to being reported or as a result of an admin review.
 

Write a solution to find the average daily percentage of posts that got removed after being reported as spam, rounded to 2 decimal places.

The result format is in the following example.

 

Example 1:

Input: 
Actions table:
+---------+---------+-------------+--------+--------+
| user_id | post_id | action_date | action | extra  |
+---------+---------+-------------+--------+--------+
| 1       | 1       | 2019-07-01  | view   | null   |
| 1       | 1       | 2019-07-01  | like   | null   |
| 1       | 1       | 2019-07-01  | share  | null   |
| 2       | 2       | 2019-07-04  | view   | null   |
| 2       | 2       | 2019-07-04  | report | spam   |
| 3       | 4       | 2019-07-04  | view   | null   |
| 3       | 4       | 2019-07-04  | report | spam   |
| 4       | 3       | 2019-07-02  | view   | null   |
| 4       | 3       | 2019-07-02  | report | spam   |
| 5       | 2       | 2019-07-03  | view   | null   |
| 5       | 2       | 2019-07-03  | report | racism |
| 5       | 5       | 2019-07-03  | view   | null   |
| 5       | 5       | 2019-07-03  | report | racism |
+---------+---------+-------------+--------+--------+
Removals table:
+---------+-------------+
| post_id | remove_date |
+---------+-------------+
| 2       | 2019-07-20  |
| 3       | 2019-07-18  |
+---------+-------------+
Output: 
+-----------------------+
| average_daily_percent |
+-----------------------+
| 75.00                 |
+-----------------------+
Explanation: 
The percentage for 2019-07-04 is 50% because only one post of two spam reported posts were removed.
The percentage for 2019-07-02 is 100% because one post was reported as spam and it was removed.
The other days had no spam reports so the average is (50 + 100) / 2 = 75%
Note that the output is only one number and that we do not care about the remove dates.*/


Solutions - 


/*Write your MySQL query statement below
with cte as(    
    select a.post_id, action_date, remove_date,
    100*round(sum(case when remove_date is not null then 1 else 0 end)/
    count(*),2) as per
    from actions a left join removals r
    on a.post_id = r.post_id
    where extra = 'spam'
    group by action_date
)
select round(avg(per),2) as average_daily_percent 
from cte */

WITH daily AS (
  SELECT
    a.action_date,
    COUNT(DISTINCT a.post_id) AS reported_posts,
    COUNT(DISTINCT CASE WHEN r.post_id IS NOT NULL THEN a.post_id END) AS removed_posts
  FROM Actions a
  LEFT JOIN Removals r
    ON r.post_id = a.post_id
  WHERE a.action = 'report'
    AND a.extra = 'spam'
  GROUP BY a.action_date
)
SELECT
  ROUND(AVG(removed_posts * 100.0 / reported_posts), 2) AS average_daily_percent
FROM daily;


/*
# Write your MySQL query statement below
with action as (
    select 
        action_date,
        post_id
    from actions
    where 
        action = 'report'
        and extra = 'spam'
),
remove as (
    select
        action_date,
        100 * count(distinct case when b.post_id is not null then b.post_id end) / count(distinct a.post_id) as daily_rate 
    from action a 
    left join Removals b 
        on a.post_id = b.post_id
    group by 1
)
select 
    round(avg(daily_rate)
        ,2) as average_daily_percent
from remove */
