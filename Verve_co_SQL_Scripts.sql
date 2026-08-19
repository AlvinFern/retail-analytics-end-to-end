use verve_co;

-- Data cleaning
select * from dim_customers;

update dim_inventory
set stock_quantity = null 
where stock_quantity = ' ';

alter table dim_customers
drop column `MyUnknownColumn_[3]`;

-- Converting str to date

-- Fact Sales

select * from fact_sales;

update fact_sales
set return_date = null where return_date = "";

UPDATE fact_sales
SET return_date = STR_TO_DATE(return_date, '%d/%m/%Y')
WHERE return_date IS NOT NULL
AND return_date != '';

ALTER TABLE fact_sales MODIFY COLUMN return_date DATE;

-- Dim Date

select * from dim_date;

SET SQL_SAFE_UPDATES = 0;

UPDATE dim_date
SET full_date = STR_TO_DATE(full_date, '%d/%m/%Y'); 

Alter table dim_date
modify column full_date date;

-- Convert day, month, year to integers
ALTER TABLE dim_date MODIFY COLUMN day INT;
ALTER TABLE dim_date MODIFY COLUMN month INT;
ALTER TABLE dim_date MODIFY COLUMN quarter INT;
ALTER TABLE dim_date MODIFY COLUMN year INT;
ALTER TABLE dim_date MODIFY COLUMN is_weekend INT;

-- Dim Customers

select * from dim_customers;

update dim_customers
set join_date = str_to_date(join_date, '%d/%m/%Y');

alter table dim_customers modify column join_date date;

-- Dim Inventory

select * from dim_inventory;

describe dim_inventory;

update dim_inventory
set last_restocked_date = null 
where last_restocked_date = "";

UPDATE dim_inventory
SET last_restocked_date = STR_TO_DATE(last_restocked_date, '%d/%m/%Y%h:%i:%s%p')
WHERE last_restocked_date IS NOT NULL;

ALTER TABLE dim_inventory
modify column last_restocked_date date;

-- dim stores

select* from dim_stores;

update dim_stores
set open_date = str_to_date(open_date, '%d/%m/%Y');

alter table dim_stores
modify column open_date date;

-- Analysis

-- What is the overall return rate (returns as % of total sales) and how has it trended year over year?

-- Overall return rate percentage
SELECT 
    COUNT(*) AS total_transactions,
    SUM(is_return) AS total_returns,
    ROUND(SUM(is_return) / COUNT(*) * 100) AS return_rate_pct
FROM fact_sales;

-- return rate percentage
Select 
	`year` as year,
	COUNT(*) AS total_transactions,
	SUM(is_return) AS total_returns,
    ROUND(SUM(is_return) / COUNT(*) * 100,2) AS return_rate_pct
FROM fact_sales f
left join dim_date d on f.date_id = d.date_id
group by year;



-- Year over Year percentage change
WITH yearly AS (
    SELECT 
        d.year,
        COUNT(*) AS total_transactions,
        SUM(f.is_return) AS num_of_returns,
        ROUND(SUM(f.is_return) / COUNT(*) * 100, 2) AS return_pct
    FROM fact_sales f
    JOIN dim_date d ON d.date_id = f.date_id
    GROUP BY d.year
)
SELECT 
    year,
    total_transactions,
    num_of_returns,
    return_pct,
    LAG(return_pct) OVER (ORDER BY year)  AS prev_year_pct,
    ROUND(return_pct - LAG(return_pct) OVER (ORDER BY year), 2)  AS yoy_change
FROM yearly
ORDER BY year;

-- What were major reasons mentioned for the returns? 

select return_reason, count(*) as num_of_returns 
from fact_sales
where is_return = 1 and return_reason != 'Unknown'
group by return_reason
order by num_of_returns desc;

-- Category and reasons for returns

select 
    category, 
    return_reason, 
    count(*) as num_of_returns 
from fact_sales f join dim_products p on f.product_id = p.product_id
where is_return = 1 and return_reason != 'Unknown'
group by return_reason, category
order by category, num_of_returns desc;

select 
	store_type,
    return_reason, 
    count(*) as num_of_returns 
from fact_sales f 
join dim_stores s on s.store_id = f.store_id
where is_return = 1 and return_reason != 'Unknown'
group by store_type, return_reason
order by store_type, num_of_returns desc;

select 
	return_reason, 
    count(*) as num_of_returns 
from fact_sales
where is_return = 1 and return_reason != 'Unknown'
group by return_reason
order by num_of_returns desc;


-- What is the average time between purchase date and return date by category?

select 
		category,
		full_date,
		return_date,
		datediff(return_date, full_date) as time_taken
	from fact_sales f
	join dim_date d on d.date_id = f.date_id
	join dim_products p on p.product_id = f.product_id
	where is_return = 1 and return_date is not null ;

with date_diff as 
	(select 
		category,
		full_date,
		return_date,
		datediff(return_date, full_date) as time_taken
	from fact_sales f
	join dim_date d on d.date_id = f.date_id
	join dim_products p on p.product_id = f.product_id
	where is_return = 1 and return_date is not null)
select 
category, 
round(avg(time_taken)) as avg_time
from date_diff 
group by category
order by 2 desc;

-- What is total amount of refunds over the years? 

select 
	year(return_date) as year, 
    round(sum(refund_amount),1) as total_refund
from fact_sales 
where return_date is not null
group by year
order by 1;

-- YoY % of refund amount

with yearly_refund as (
	select 
		year(return_date) as year, 
		round(sum(refund_amount),1) as total_refund
	from fact_sales 
	where return_date is not null
	group by year
	order by 1)
select 
year,
total_refund,
lag(total_refund) over(order by year) as prev_refund,
round((total_refund/lag(total_refund) over(order by year) - 1) *100,1) as year_over_year 
from yearly_refund;



-- Which product category and sub-category has the most returns and how much were refunded?

-- Answered in Power BI

-- Which month of the year over the last 3 years had the most returns? 

select 
	year(return_date) as year,
    monthname(return_date) as months,
    sum(is_return) as number_of_returns
from fact_sales
where return_date is not null
group by months, year
order by 1, 3 desc;
    

-- Which store locations received the highest returns? Are physical store returns higher than online?



-- Is there pattern for a particular brand that customers returned products? 

select 
	category,
    brand,
    return_reason,
    sum(is_return) as no_of_returns
from fact_sales f
join dim_products p on p.product_id = f.product_id
group by brand, category, return_reason
order by 1, 3 desc;


-- Reasons for the return for popular brands
with popular_brand as (
	select 
	category,
    brand,
    return_reason,
    sum(is_return) as no_of_returns
from fact_sales f
join dim_products p on p.product_id = f.product_id
where is_return = 1
group by brand, category, return_reason
order by 1, 3 desc)
Select 
	brand, 
    return_reason,
    no_of_returns
from popular_brand
where brand in ('HP', 'Apple')
order by 1, 3 desc;

-- Did the price of the products influence them to return?

select distinct(return_reason) from fact_sales where is_return = 1;

with popular_brand as (
	select 
	category,
    brand,
    return_reason,
    sum(is_return) as no_of_returns
from fact_sales f
join dim_products p on p.product_id = f.product_id
where is_return = 1
group by brand, category, return_reason
order by 1, 3 desc)
Select 
	brand, 
    return_reason,
    no_of_returns
from popular_brand
where return_reason = 'Better price elsewhere'
order by  3 desc;

-- What is the amount of customers who returned items due to 'better price elsewhere'

Select 
	return_reason,
    sum(is_return) as no_of_returns,
    round(sum(is_return)/
		(select 
			sum(is_return) as no_of_customers
		from fact_sales
		where is_return = 1
		)*100) as pct_of_returns
from fact_sales
where is_return = 1
group by return_reason
order by pct_of_returns desc
;

-- How much revenue (refund amount) did it cost for each reasons every year? 

select 
	return_reason,
    year(return_date) as year,
    round(sum(refund_amount)) as total_refund
from fact_sales
where is_return = 1 and return_date is not null
group by return_reason, year
order by 2, 3 desc;

-- Which category was affected the most for revenue lost in refunds?
select 
    category,
    year(return_date) as year,
    round(sum(refund_amount)) as total_refund,
    rank() over(partition by year(return_date) order by round(sum(refund_amount)) desc) as rank_num
from fact_sales f join dim_products p on p.product_id = f.product_id
where is_return = 1 and return_date is not null
group by category, year
order by 2, 3 desc;

Select category, count(*) as num from fact_sales f 
join dim_products p on p.product_id = f.product_id 
where return_reason like 'Better%'
group by category
order by 2 desc;

-- Category return reasons
Select 
	category,
    return_reason,
    count(*) as num
from fact_sales f join dim_products p on p.product_id = f.product_id
where is_return = 1 and category like 'Sport%'
group by 1, 2
order by 3 desc;

-- How many store we have in each state

Select 
	state,
    count(store_name) as num_of_stores
from dim_stores
group by state order by num_of_stores desc;

-- reason of return for each state

 select * from (Select 
	store_name,
    return_reason,
    count(*) as num_of_customers
from fact_sales f 
join dim_stores s on s.store_id = f.store_id
where is_return = 1 and state != ''
group by 1, 2
order by 1, 3 desc) a 
where a.store_name like 'Denver%'; 

-- Online store return reasons

Select 
    store_type,
    return_reason,
    count(*) as num_of_returns
from fact_sales f join dim_stores s on f.store_id = s.store_id
join dim_date d on f.date_id = d.date_id
where is_return = 1 and store_type = 'E-Commerce'
group by 1, 2
order by 3 desc;

Select 
	year,
    store_type,
    return_reason,
    count(*) as num_of_returns
from fact_sales f join dim_stores s on f.store_id = s.store_id
join dim_date d on f.date_id = d.date_id
where is_return = 1 and store_type = 'E-Commerce'
group by 1, 2, 3
order by 1, 4 desc;


-- Uneven Store Performance & Inventory

-- 1. What is our total revenue, profit and sales for every store? 
-- Which stores are underperforming and why? 

Select
    city,
    store_name, 
    count(sale_id) as sales,
    round(sum(total_amount),2) as revenue,
    round(sum(unit_cost),2) as cost,
    round(sum(total_amount) - sum(unit_cost),2) as profit
from fact_sales f join dim_stores s on f.store_id = s.store_id
join dim_products p on p.product_id = f.product_id
where is_return = 0
group by 1,2
order by 6 desc ;

with performance as (Select
    city,
    store_name, 
    count(sale_id) as sales,
    round(sum(total_amount),2) as revenue,
    round(sum(unit_cost),2) as cost,
    round(sum(total_amount) - sum(unit_cost),2) as profit
from fact_sales f join dim_stores s on f.store_id = s.store_id
join dim_products p on p.product_id = f.product_id
where is_return = 0
group by 1,2
order by 6 desc)

select 
	city,
    store_name,
    sales,
    revenue,
    case when sales > 175 and revenue > 135000 then 'Best Performing'
    when sales between 160 and 170 and revenue < 120000 then 'Under Performing'
    when sales <150 and revenue < 90000 then 'Bad Performing'
    else 'Mediocore Performing' end as store_performance
    from performance;
    
    WITH performance AS (
    SELECT
        s.city,
        s.store_name,
        s.store_type,
        COUNT(f.sale_id)                                    AS sales,
        ROUND(SUM(f.total_amount), 2)                       AS revenue,
        ROUND(SUM(p.unit_cost), 2)                          AS cost,
        ROUND(SUM(f.total_amount) - SUM(p.unit_cost), 2)   AS profit
    FROM fact_sales f 
    JOIN dim_stores s   ON f.store_id   = s.store_id
    JOIN dim_products p ON p.product_id = f.product_id
    WHERE f.is_return = 0
    GROUP BY s.city, s.store_name, s.store_type
),
ranked AS (
    SELECT
        city,
        store_name,
        store_type,
        sales,
        revenue,
        profit,
        NTILE(4) OVER (ORDER BY profit DESC)                AS profit_quartile
    FROM performance
)
SELECT
    city,
    store_name,
    store_type,
    sales,
    revenue,
    profit,
    profit_quartile,
    CASE profit_quartile
        WHEN 1 THEN 'Best Performing'
        WHEN 2 THEN 'Good Performing'
        WHEN 3 THEN 'Under Performing'
        WHEN 4 THEN 'Poor Performing'
    END                                                     AS store_performance
FROM ranked
ORDER BY profit DESC;

-- Which products are consistently selling below their reorder level threshold, 
-- and which are at risk of stockout?

select 
	product_name,
    store_name,
    stock_quantity,
    reorder_level,
    last_restocked_date
from dim_inventory i join dim_products p on i.product_id = p.product_id
join dim_stores s on s.store_id = i.store_id
order by 1, 2;

with reorder as (
select 
    p.category,
    p.product_name,
    stock_quantity,
    reorder_level,
    last_restocked_date
from dim_inventory i join dim_products p on i.product_id = p.product_id
),

units as (select
    p.category,
    p.product_name,
    sum(quantity) as units
from fact_sales f join dim_products p on f.product_id = p.product_id
group by 1, 2
order by 2 desc)

select 
	r.category,
    r.product_name, 
	units, 
    stock_quantity,
    reorder_level,
    r.last_restocked_date
from reorder r join units u on r.product_name = u.product_name
where stock_quantity < reorder_level
order by 3 desc
;

select
    product_name,
    sum(quantity) as units
from fact_sales f join dim_products p on f.product_id = p.product_id
group by 1
order by 2 desc;

-- How does store performance compare across store types — Flagship, Standard, and Outlet?

select
	store_type,
    round(sum(total_amount),2) as revenue,
    round(sum(unit_cost),2) as cost,
    round(sum(total_amount) - sum(unit_cost),2) as profit
from fact_sales f join dim_stores s on f.store_id = s.store_id
join dim_products p on p.product_id = f.product_id
where is_return = 0
group by 1
order by 4 desc;
    
-- Which stores currently have products at or below the reorder level, 
-- and which have overstocked products (stock significantly above reorder level)?

with stock_status as (Select 
	store_name,
    category,
    product_name,
    stock_quantity,
    reorder_level,
    CASE 
    WHEN stock_quantity IS NULL                        THEN 'Unknown'
    WHEN stock_quantity = 0                            THEN 'Stockout'
    WHEN stock_quantity <= reorder_level               THEN 'Reorder Risk'
    WHEN stock_quantity <= reorder_level * 2           THEN 'Healthy'
    WHEN stock_quantity <= reorder_level * 3           THEN 'Overstock'
    WHEN stock_quantity > reorder_level * 3            THEN 'Severe Overstock'
END AS stock_status

from dim_stores s join dim_inventory i on s.store_id = i.store_id
join dim_products p on p.product_id = i.product_id
),
stck_status as (Select *, rank() over(partition by category order by stock_quantity) as priority 
from stock_status)

select stock_status, count(*) as num from stck_status group by 1 order by 2 desc;

WITH stock_status AS (
    SELECT 
        s.store_name,
        p.category,
        p.product_name,
        i.stock_quantity,
        i.reorder_level,
        CASE 
            WHEN i.stock_quantity IS NULL                   THEN 'Unknown'
            WHEN i.stock_quantity = 0                       THEN 'Stockout'
            WHEN i.stock_quantity <= i.reorder_level        THEN 'Reorder Risk'
            WHEN i.stock_quantity <= i.reorder_level * 2    THEN 'Healthy'
            WHEN i.stock_quantity <= i.reorder_level * 3    THEN 'Overstock'
            WHEN i.stock_quantity > i.reorder_level * 3     THEN 'Severe Overstock'
        END                                                 AS stock_status
    FROM dim_stores s 
    JOIN dim_inventory i ON s.store_id   = i.store_id
    JOIN dim_products p  ON p.product_id = i.product_id
)
SELECT 
    stock_status,
    COUNT(*)                                                AS num
FROM stock_status
GROUP BY stock_status
ORDER BY num DESC;

-- Whats the sales and stock quantity 

SELECT 
    p.product_name,
    p.category,
    s.store_name,
    i.stock_quantity,
    i.reorder_level,
    i.last_restocked_date,
    SUM(f.quantity) AS total_units_sold,
    CASE WHEN i.stock_quantity <= i.reorder_level AND SUM(f.quantity) > 50  THEN 'High Demand - Restock Urgently'
        WHEN i.stock_quantity <= i.reorder_level 
         AND SUM(f.quantity) <= 50 THEN 'Low Sales - Investigate Restocking'
        ELSE 'Healthy'
    END AS stock_diagnosis
FROM dim_inventory i
JOIN dim_products p  ON p.product_id = i.product_id
JOIN dim_stores s    ON s.store_id   = i.store_id
JOIN fact_sales f    ON f.product_id = i.product_id
                     AND f.store_id  = i.store_id
WHERE i.stock_quantity <= i.reorder_level
AND i.stock_quantity IS NOT NULL
AND f.quantity > 0
GROUP BY 
    p.product_name, p.category, s.store_name,
    i.stock_quantity, i.reorder_level, i.last_restocked_date
ORDER BY total_units_sold DESC;

-- What is the revenue and sales volume split between physical stores and the online store, 


Select 
	case when store_type = 'E-commerce' then 'online'
    else 'Physical Store' end as store,
    round(sum(total_amount),1) as revenue,
    round(sum(quantity),1) as sales_volume
from fact_sales f join dim_stores s on f.store_id = s.store_id
group by store
order by revenue desc;
    

-- How has the online channel grown year over year?

Select 
	store_type,
    `year` as year,
    round(sum(total_amount),2) as revenue
from fact_sales f join dim_stores s on s.store_id = f.store_id
join dim_date d on d.date_id = f.date_id
where store_type = 'E-Commerce'
group by 1,2 
order by 2;
    
    
WITH store_rev AS (
    SELECT 
        d.year,
        ROUND(SUM(f.total_amount), 2)                    AS gross_revenue,
        ROUND(SUM(COALESCE(f.refund_amount, 0)), 2)      AS total_refunds,
        ROUND(SUM(f.total_amount) - 
              SUM(COALESCE(f.refund_amount, 0)), 2)      AS net_revenue
    FROM fact_sales f 
    JOIN dim_stores s ON s.store_id = f.store_id
    JOIN dim_date d   ON d.date_id  = f.date_id
    WHERE s.store_type = 'E-commerce'
    GROUP BY d.year
)
SELECT 
    year,
    gross_revenue,
    total_refunds,
    net_revenue,
    LAG(net_revenue) OVER (ORDER BY year)                AS prev_year_net_revenue,
    ROUND(
        ((net_revenue / LAG(net_revenue) 
        OVER (ORDER BY year)) - 1) * 100
    , 1)                                                 AS yoy_pct
FROM store_rev
ORDER BY year;


-- Problem 3 - Shifting Customer Base & Loyalty Concerns

-- What is the RFM score for each customer, and how are customers distributed across RFM segments?

-- Recency
select 
	f.customer_id,
    c.city,
    c.state,
    max(full_date) as last_purchased_date,
    datediff('2024-12-31', max(full_date)) as recency_days
from fact_sales f join dim_customers c on f.customer_id = c.customer_id
join dim_date d on f.date_id = d.date_id
group by f.customer_id, c.city, c.state
order by recency_days;

-- Frequency
select 
	f.customer_id,
    c.city,
    c.state,
    count(*) as num_of_purchases
from fact_sales f join dim_customers c on f.customer_id = c.customer_id
group by f.customer_id, c.city, c.state
order by num_of_purchases desc;

-- Monetory
select 
	f.customer_id,
    c.city,
    c.state,
    round(sum(total_amount),1) as customer_revenue
from fact_sales f join dim_customers c on f.customer_id = c.customer_id
group by 1, 2, 3
order by customer_revenue desc;

with recency as (select 
	f.customer_id,
    c.city,
    c.state,
    max(full_date) as last_purchased_date,
    datediff('2024-12-31', max(full_date)) as recency_days
from fact_sales f join dim_customers c on f.customer_id = c.customer_id
join dim_date d on f.date_id = d.date_id
group by f.customer_id, c.city, c.state
order by recency_days),

-- Frequency
 frequency as (select 
	f.customer_id,
    c.city,
    c.state,
    count(*) as num_of_purchases
from fact_sales f join dim_customers c on f.customer_id = c.customer_id
group by f.customer_id, c.city, c.state
order by num_of_purchases desc),

-- Monetory
monetory as (select 
	f.customer_id,
    c.city,
    c.state,
    round(sum(total_amount),1) as customer_revenue
from fact_sales f join dim_customers c on f.customer_id = c.customer_id
group by 1, 2, 3
order by customer_revenue desc),

rfm_base as (
Select 
	r.customer_id,
    r.city,
    r.state,
    recency_days,
    num_of_purchases,
    customer_revenue
from recency r join frequency f on r.customer_id = f.customer_id
join monetory m on r.customer_id = m.customer_id),

rfm_scores as (
Select 
	customer_id,
    city,
    state,
    recency_days,
    num_of_purchases,
    customer_revenue,
   -- Recency 
   case when recency_days <= 180 then 3
	when recency_days <= 540 then 2
    else 1 end as r_score,
    -- Frequency
    case when num_of_purchases >= 10 then 3
    when num_of_purchases >= 5 then 2
    else 1 end as f_score,
    -- Monetary
    case when customer_revenue >= 5000 then 3 
    when customer_revenue >= 2000 then 2
    else 1 end as m_score
from rfm_base),

rfm as (Select 
    customer_id,
    city,
    state,
    recency_days,
    num_of_purchases,
    customer_revenue,
    r_score,
    f_score,
    m_score,
    case when r_score = 3 and f_score = 3 and m_score = 3 then 'Champion'
    when r_score >= 2 and f_score = 3 and m_score >= 3 then 'Loyalty Customer'
    when r_score = 3 and f_score >= 2 and m_score >= 2 then 'Potential Loyalist'
	when r_score = 3 and f_score = 1 and m_score = 1 then 'New Customer'
	when r_score = 1 and f_score >= 2 and m_score >= 2 then 'At Risk'
	when r_score = 1 and f_score = 3 and m_score = 3  then 'Cannot Lose'
	when r_score = 1 and f_score = 1 and m_score = 1 then 'Hibernating'
	WHEN r_score = 2 AND f_score = 2 AND m_score = 2 THEN 'Average Customer'      
    WHEN r_score = 2 AND f_score = 1 AND m_score = 1 THEN 'Occasional Buyer'       
    WHEN r_score = 2 AND f_score = 2 AND m_score = 3 THEN 'Promising'              
    WHEN r_score = 2 AND f_score = 1 AND m_score = 2 THEN 'Occasional Buyer'       
    WHEN r_score = 3 AND f_score = 1 AND m_score = 2 THEN 'High Value New Buyer'   
    WHEN r_score = 3 AND f_score = 2 AND m_score = 1 THEN 'Recent Low Spender'    
	else 'Needs Attention'
	end as rfm_segment
from rfm_scores
order by customer_revenue desc)

SELECT 
    rfm_segment,
    count(*)
from rfm
group by 1
order by 2 desc;


with recency as (select 
	f.customer_id,
    c.city,
    c.state,
    max(full_date) as last_purchased_date,
    datediff('2024-12-31', max(full_date)) as recency_days
from fact_sales f join dim_customers c on f.customer_id = c.customer_id
join dim_date d on f.date_id = d.date_id
group by f.customer_id, c.city, c.state
order by recency_days),

-- Frequency
 frequency as (select 
	f.customer_id,
    c.city,
    c.state,
    count(*) as num_of_purchases
from fact_sales f join dim_customers c on f.customer_id = c.customer_id
group by f.customer_id, c.city, c.state
order by num_of_purchases desc),

-- Monetory
monetory as (select 
	f.customer_id,
    c.city,
    c.state,
    round(sum(total_amount),1) as customer_revenue
from fact_sales f join dim_customers c on f.customer_id = c.customer_id
group by 1, 2, 3
order by customer_revenue desc),

rfm_base as (
Select 
	r.customer_id,
    r.city,
    r.state,
    recency_days,
    num_of_purchases,
    customer_revenue
from recency r join frequency f on r.customer_id = f.customer_id
join monetory m on r.customer_id = m.customer_id),

rfm_scores as (
Select 
	customer_id,
    city,
    state,
    recency_days,
    num_of_purchases,
    customer_revenue,
   -- Recency 
   case when recency_days <= 180 then 3
	when recency_days <= 540 then 2
    else 1 end as r_score,
    -- Frequency
    case when num_of_purchases >= 10 then 3
    when num_of_purchases >= 5 then 2
    else 1 end as f_score,
    -- Monetary
    case when customer_revenue >= 5000 then 3 
    when customer_revenue >= 2000 then 2
    else 1 end as m_score
from rfm_base),

rfm as (Select 
    customer_id,
    city,
    state,
    recency_days,
    num_of_purchases,
    customer_revenue,
    r_score,
    f_score,
    m_score,
    case when r_score = 3 and f_score = 3 and m_score = 3 then 'Champion'
    when r_score >= 2 and f_score = 3 and m_score >= 3 then 'Loyalty Customer'
    when r_score = 3 and f_score >= 2 and m_score >= 2 then 'Potential Loyalist'
	when r_score = 3 and f_score = 1 and m_score = 1 then 'New Customer'
	when r_score = 1 and f_score >= 2 and m_score >= 2 then 'At Risk'
	when r_score = 1 and f_score = 3 and m_score = 3  then 'Cannot Lose'
	when r_score = 1 and f_score = 1 and m_score = 1 then 'Hibernating'
	WHEN r_score = 2 AND f_score = 2 AND m_score = 2 THEN 'Average Customer'      
    WHEN r_score = 2 AND f_score = 1 AND m_score = 1 THEN 'Occasional Buyer'       
    WHEN r_score = 2 AND f_score = 2 AND m_score = 3 THEN 'Promising'              
    WHEN r_score = 2 AND f_score = 1 AND m_score = 2 THEN 'Occasional Buyer'       
    WHEN r_score = 3 AND f_score = 1 AND m_score = 2 THEN 'High Value New Buyer'   
    WHEN r_score = 3 AND f_score = 2 AND m_score = 1 THEN 'Recent Low Spender'    
	else 'Needs Attention'
	end as rfm_segment
from rfm_scores
order by customer_revenue desc)

SELECT 
    rfm_segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / 499, 1) AS pct_of_base
FROM rfm
GROUP BY rfm_segment
ORDER BY customer_count DESC;

-- What is the Average Order value and Customer lifetime value for different types of customers? 
-- Identify opportunities for growth and optimization. 

-- AOV and CLV
WITH clv_base AS (
    SELECT 
        c.customer_segment,
        COUNT(DISTINCT f.customer_id)               AS num_customers,
        COUNT(f.sale_id)                            AS total_orders,
        ROUND(SUM(f.total_amount), 2)               AS total_revenue
    FROM fact_sales f
    JOIN dim_customers c ON c.customer_id = f.customer_id
    WHERE f.is_return = 0
    GROUP BY c.customer_segment
)
SELECT 
    customer_segment,
    num_customers,
    total_orders,
    total_revenue,
    -- AOV = revenue per transaction
    ROUND(total_revenue / total_orders, 2)                          AS aov,
    -- Purchase frequency = orders per customer
    ROUND(total_orders / num_customers, 2)                          AS purchase_frequency,
    -- CLV = AOV x frequency x lifespan (3 years)
    ROUND((total_revenue / total_orders) * 
          (total_orders / num_customers) * 3, 1)                   AS clv
FROM clv_base
ORDER BY clv DESC;

-- What are the product category and price range preferences for each customer segment?

select 
	c.customer_segment,
    p.category,
    count(f.sale_id) as num_of_customer
from fact_sales f join dim_customers c on c.customer_id = f.customer_id
join dim_products p on p.product_id = f.product_id
where is_return = 0
group by 1,2
order by 1,3 desc;


select 
	c.customer_segment,
    p.category,
    count(distinct c.customer_id) as num_of_customer,
	CASE 
        WHEN p.unit_price < 50                  THEN 'Budget (< $50)'
        WHEN p.unit_price BETWEEN 50 AND 200    THEN 'Mid-Range ($50-$200)'
        WHEN p.unit_price BETWEEN 200 AND 500   THEN 'Premium ($200-$500)'
        WHEN p.unit_price > 500                 THEN 'Luxury (> $500)'
    END                                         AS price_range
from fact_sales f join dim_customers c on c.customer_id = f.customer_id
join dim_products p on p.product_id = f.product_id
where is_return = 0
group by 1,2,4
order by 1,3 desc;

Select customer_segment, count(distinct customer_id) as num_of_customers
from dim_customers 
group by 1 order by 2 desc;


-- Which customers haven't purchased in the last 6–12 months and were previously frequent buyers?

-- Customer segments with inactive number of customers
with customers as (Select 
	f.customer_id,
    customer_segment,
    max(full_date) as latest_purchase,
    datediff('2024-12-31', max(full_date)) as day_since_last_purchase,
    round(sum(total_amount),1) as total_spent
from fact_sales f join dim_date d on d.date_id = f.date_id 
join dim_customers c on c.customer_id = f.customer_id
where is_return = 0
group by 1,2),

churn as (Select 
	*,
    case when day_since_last_purchase between 180 and 365 then 'Lapsing'
    when day_since_last_purchase > 365 then 'Churned'
    end as churn_status
from customers
where day_since_last_purchase between 180 and 365 -- inactive for 6-12 months
order by total_spent desc),

customer_segments as (Select customer_segment, count(distinct customer_id) as num_of_customers
from dim_customers 
group by 1 order by 2 desc)

select 
	c.customer_segment, 
	s.num_of_customers, 
    count(*) as num_of_inactive_customers,
    round((count(*)	/num_of_customers)*100) as pct_inactive
from churn c join customer_segments s on c.customer_segment = s.customer_segment 
group by 1
order by 4 desc;

-- Lapsing customers 
with customers as (Select 
	f.customer_id,
    customer_segment,
    max(full_date) as latest_purchase,
    datediff('2024-12-31', max(full_date)) as day_since_last_purchase,
    round(sum(total_amount),1) as total_spent
from fact_sales f join dim_date d on d.date_id = f.date_id 
join dim_customers c on c.customer_id = f.customer_id
where is_return = 0
group by 1,2)

Select 
	*,
    case when day_since_last_purchase between 180 and 365 then 'Lapsing'
    when day_since_last_purchase > 365 then 'Churned'
    end as churn_status
from customers
where day_since_last_purchase between 180 and 365  -- inactive for 6-12 months
order by total_spent desc;


-- How has the customer segment mix shifted year over year from 2022 to 2024

Select 
	year(full_date) as year,
    customer_segment, 
    count(distinct f.customer_id) as num_of_customer,
    round(sum(total_amount)/count(f.sale_id),1) as Aov
from dim_customers c join fact_sales f on f.customer_id = c.customer_id 
join dim_date d on d.date_id = f.date_id
where is_return = 0
group by 1,2
order by 1,3 desc;



with customer_segments as (Select 
	year(full_date) as year,
    customer_segment, 
    count(distinct f.customer_id) as num_of_customer,
    round(sum(total_amount)/count(f.sale_id),1) as Aov
from dim_customers c join fact_sales f on f.customer_id = c.customer_id 
join dim_date d on d.date_id = f.date_id
where is_return = 0
group by 1,2
)

Select 
	year,
    customer_segment,
    num_of_customer,
    lag(num_of_customer) over(partition by customer_segment order by year) as prev_year_customers,
    round((num_of_customer/lag(num_of_customer) over(partition by customer_segment order by year)-1)*100,1) as YoY_pct
from customer_segments    
;


SELECT 
    MONTH(d.full_date)      AS month,
    YEAR(d.full_date)       AS year,
    COUNT(*)                AS transactions,
    SUM(f.is_return)        AS returns,
    ROUND(SUM(f.is_return) / COUNT(*) * 100, 1) AS return_rate
FROM fact_sales f
JOIN dim_date d ON d.date_id = f.date_id
GROUP BY YEAR(d.full_date), MONTH(d.full_date)
ORDER BY year, month;





select 
	year(full_date) as year,
    store_type,
	return_reason,
    sum(is_return) as num_returns
from fact_sales f join dim_stores s on s.store_id = f.store_id
join dim_date d on d.date_id = f.date_id
group by 1,2,3
order by 1, 2, 4 desc;


select product_name, brand, customer_segment, count(sale_id) as num_sales from fact_sales f join
dim_products p on f.product_id = p.product_id join dim_customers c
on c.customer_id = f.customer_id
where customer_segment = 'Premium'
group by 1,2
order by 4 desc;








