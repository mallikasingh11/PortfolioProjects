-- The Sales Dataset (head)
SELECT * FROM sales
LIMIT 10;

-- How was the sales trend over the months?
SELECT year(date), month(date), count(*) AS num_sales FROM sales
GROUP BY year(date), month(date)
ORDER BY num_sales DESC, year(date) ASC, month(date) ASC;

-- September, October and November in 2019 had the highest total number of sales from the dataset
-- February, April and December in 2019 had the lowest total number

-- What are the most frequently purchased products?

SELECT productname, COUNT(productname) AS num_orders_per_prod FROM sales
GROUP BY productname
ORDER BY num_orders_per_prod DESC;

-- How many products were only bought one time in this dataset?
-- count number of times the count of something is one

SELECT COUNT(*) as num_prods_sold_once FROM
    (SELECT productname, COUNT(productname) AS num_orders_per_prod FROM sales
    GROUP BY productname
    HAVING num_orders_per_prod = 1
    ORDER BY num_orders_per_prod ASC)
;

-- There are 126 products that have only been sold one time.

-- How many products does the customer purchase in each transaction (not overall)?

    -- total number of products 
    -- group by transaction
    -- group by customer?

SELECT customerno, transactionno, SUM(quantity) total_prods_per_cust FROM sales
GROUP BY customerno, transactionno
ORDER BY total_prods_per_cust DESC;

-- Customer 16446 bought 80,995 products.

-- What customers spent the most? How many transactions did this customer have?

SELECT customerno, sum(price*quantity) AS total_spent FROM sales
GROUP BY customerno
ORDER BY total_spent DESC;

SELECT * FROM sales
WHERE customerno = 16446 and customerno <> 'NA';

-- Customer 16446 spent a total of $485,994 with 4 transactions, one of which was a cancellation


-- How many distinct transactions are there vs distinct customers?
SELECT COUNT(DISTINCT(customerno)), COUNT(DISTINCT(transactionno)) FROM sales;

-- 23,204 transactions are split amongst 4,739 customers

-- The split is found in the query below:
SELECT customerno, COUNT(DISTINCT(transactionno)) FROM sales
GROUP BY customerno;


-- Examining seasonal products
SELECT productname, COUNT(productname) AS num_some_orders, month(date) FROM sales
WHERE productname LIKE '% Christmas %'
GROUP BY productname, month(date);

-- Add a revenue column for each transaction

ALTER TABLE sales ADD COLUMN revenue INT;
UPDATE sales SET revenue = price * quantity;

-- Which products generated the most revenue overall in November?

SELECT top 3 month(date), productname, SUM(revenue) FROM sales
WHERE month(date) = '11'
GROUP BY month(date), productname
ORDER BY sum(revenue) desc;

-- A christmas item is one of the top three purchased items in November

-- Examining which days of the week have more orders
SELECT COUNT(transactionno) AS sum_orders, dayofweek(date) FROM sales
WHERE year(date) = 2019
GROUP BY dayofweek(date)
ORDER BY sum_orders DESC;

-- Sunday and Friday have the most purchases.



-- Key Findings
-- - In 2019, September, October and November were the months with the highest number of sales
-- - The top three products with the most orders were the Cream Hanging Heart T-Light Holder, Regency Cakestand 3 Tier and the Jumbo Bag Red Retrospot
-- - 126 products have only been bought one time in over a year. It may be wise to discontinue these products to reduce manufacturing costs
-- - There are many christmas products but only the Paper Chain Kit 50's Christmas product was in the top three revenue generating products in November
-- - Boosting christmas product sales in November could be an area of focus

