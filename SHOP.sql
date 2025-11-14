CREATE DATABASE shop ;
USE shop ;

CREATE TABLE sales (
	transaction_id INT ,
    customer_id INT ,
    customer_name VARCHAR(50) ,
    email VARCHAR(100) ,
    purchase_date DATE ,
    product_id INT ,
    category VARCHAR(100) ,
    price DECIMAL ,
    quantity INT ,
    total_amount INT ,
    payment_method VARCHAR(50) ,
    delivery_status VARCHAR(50) ,
    customer_address VARCHAR(100)
);

SELECT * FROM sales ;

-- My task is to clean the data . I follow these Steps:-
-- Step 1 :- To check for duplicates
-- Step 2 :- Check For Null Values
-- Step 3 :- Treating Null values
-- Step 4 :- Handling Negative values
-- Step 5 :- Check email address and date
-- Step 6 :- Checking the datatype


-- Step 1 :- To check duplicate values in table
-- first of all , I find out duplicate rows

WITH cte AS ( SELECT
			* ,
			ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY transaction_id ASC) AS rw_no
			FROM sales )
SELECT * FROM cte
WHERE rw_no > 1 ;

-- After finding out duplicate row , I will delete those rows 

SET SQL_SAFE_UPDATES = 0 ;
SET AUTOCOMMIT = 0 ;

ALTER TABLE sales
ADD COLUMN s_no INT PRIMARY KEY AUTO_INCREMENT;

DELETE FROM sales
WHERE s_no IN (
  SELECT s_no FROM (
    SELECT s_no,
           ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY s_no) AS rn
    FROM sales
  ) t
  WHERE t.rn > 1
);

COMMIT ;
SET AUTOCOMMIT = 1 ;


-- Step 2 :- Check For Null Values

SELECT COUNT(*) FROM sales WHERE transaction_id IS NULL ;             -- There is no null value
SELECT COUNT(*) FROM sales WHERE customer_id IS NULL ;             	  -- There is 3 null values
SELECT COUNT(*) FROM sales WHERE customer_name IS NULL ;  			  -- There is 48 null values
SELECT COUNT(*) FROM sales WHERE email IS NULL ;					  -- There is no null value
SELECT COUNT(*) FROM sales WHERE purchase_date IS NULL ;  			  -- There is no null value
SELECT COUNT(*) FROM sales WHERE product_id IS NULL ;  				  -- There is no null value
SELECT COUNT(*) FROM sales WHERE category IS NULL ;					  -- There is 159 null values
SELECT COUNT(*) FROM sales WHERE price IS NULL ;                      -- There is 54 null values
SELECT COUNT(*) FROM sales WHERE quantity IS NULL ;					  -- There is no null value
SELECT COUNT(*) FROM sales WHERE total_amount IS NULL ;               -- There is 230 null values
SELECT COUNT(*) FROM sales WHERE payment_method IS NULL ;			  -- There is 129 null values
SELECT COUNT(*) FROM sales WHERE delivery_status IS NULL ;			  -- There is 120 null values
SELECT COUNT(*) FROM sales WHERE customer_address IS NULL ;           -- There is 52 null values 


-- Step 3 :- Treating Null values

-- In category column , there is 159 null values . I have to replace Null values into "UnKnown".
UPDATE sales
SET category = "Unknown"
WHERE category IS NULL ;

-- In customer_address column , there is 52 null values present . I have to replace Null values into "Not Available".
UPDATE sales
SET customer_address = "Not Available"
WHERE customer_address IS NULL ;

-- In payment_method column , there is 129 null values present . I have to replace Null values into "Cash".
UPDATE sales
SET payment_method = "Cash"
WHERE payment_method IS NULL ;

-- In payment_method column , replace "creditcard" , "CC" , "credit" into "Credit Card".
UPDATE sales
SET payment_method = "Credit Card"
WHERE payment_method IN ("creditcard" , "CC" , "credit") ;    -- 352 rows affected

-- In delivery_status column , there is 120 null values present . I have to replace Null values into "Not Delivered".
UPDATE sales
SET delivery_status = "Not Delivered"
WHERE delivery_status IS NULL ;

-- In customer_name column , there is 48 null values present . I have to replace Null values into "User".
UPDATE sales
SET customer_name = "User"
WHERE customer_name IS NULL ;                                 -- 48 rows affected


-- In price column , there is 54 null values present . I have to replace Null values into Average to their particular category.
 SELECT category , ROUND(AVG(price),2) AS avg_price
 FROM sales 
GROUP BY category ;

-- OUTPUT :-    Category        avg_price
			 -- Unknown	        2513.31
             -- Toys	        2217.12
             -- Home & Kitchen	2536.44
             -- Electronics	    2658.57
             -- Clothing	    2522.05
             -- Books	        2540.58

-- So,I decided to give average price to their respective category.
-- Unknown
UPDATE sales
SET price = 2513.31
WHERE price IS NULL AND category = "Unknown" ;       -- 13 rows affected

-- Toys
UPDATE sales
SET price = 2217.12
WHERE price IS NULL AND category = "Toys" ;          -- 10 rows affected

-- Home & Kitchen
UPDATE sales
SET price = 2536.44
WHERE price IS NULL AND category = "Home & Kitchen" ;   -- 5 rows affected 

-- Electronics 
UPDATE sales
SET price = 2658.57
WHERE price IS NULL AND category = "Electronics";       -- 6 rows affected

-- Clothing
UPDATE sales
SET price = 2522.05
WHERE price IS NULL AND category = "Clothing";         -- 11 rows affected

-- Books
UPDATE sales
SET price = 2540.58
WHERE price IS NULL AND category = "Books";            -- 9 rows affected


-- Step 4 :- Handling Negative values
-- Negative values is present in quantity column and total_amount column

-- Select rows of Negative value of quantity column
SELECT * FROM sales
WHERE quantity < 0 ;

UPDATE sales
SET quantity = ABS(quantity)
WHERE quantity < 0 ;                                 -- 297 rows affected

UPDATE sales
SET total_amount = price * quantity
WHERE total_amount IS NULL OR total_amount != price * quantity ;     -- 768 rows affected

UPDATE sales
SET total_amount = ROUND(total_amount,2);            -- 0 rows affected


-- Step 5 :- Check email address and date
-- find incorrect email address
SELECT email FROM sales WHERE email NOT LIKE "%@%" ;     


-- Step 6 :- Checking the datatype of all columns
DESCRIBE sales ;