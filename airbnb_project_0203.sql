-- -----------------------------------------------------
-- Schema airbnb
-- -----------------------------------------------------
CREATE SCHEMA airbnb;
USE airbnb;
-- Create tables and import CSV file data using Wizard
SELECT * FROM airbnb.customer;
SELECT * FROM airbnb.feedback;
SELECT * FROM airbnb.host;
SELECT * FROM airbnb.order;
SELECT * FROM airbnb.payment;
SELECT * FROM airbnb.property;

-- Create tables
CREATE TABLE IF NOT EXISTS airbnb.room_type (
  ROOM_TYPE_ID INT NOT NULL,
  TYPE VARCHAR(45) NOT NULL,
  PRIMARY KEY (ROOM_TYPE_ID));
CREATE TABLE IF NOT EXISTS airbnb.payment_method (
  PAYMENT_METHOD_ID INT NOT NULL,
  METHOD VARCHAR(45) NOT NULL,
  PRIMARY KEY (PAYMENT_METHOD_ID));
-- Insert values to new tables
INSERT INTO payment_method VALUES 
(1,	'CREDIT CARD'), (2, 'DEBIT CARD');
INSERT INTO room_type VALUES 
(1,	'Shared room'), (2,	'Private room'),(3,	'Entire house'), (4, 'Entire apartment');
  SELECT * FROM room_type;
  SELECT * FROM payment_method;
  
-- Adding constraints to imported tables
ALTER TABLE airbnb.customer ADD PRIMARY KEY (CUST_ID);
ALTER TABLE airbnb.property ADD PRIMARY KEY (PROPERTY_ID);
ALTER TABLE airbnb.order ADD PRIMARY KEY (Order_ID);
ALTER TABLE airbnb.payment ADD PRIMARY KEY (PAY_ID);
ALTER TABLE airbnb.feedback ADD PRIMARY KEY (FBK_ID);
ALTER TABLE airbnb.HOST ADD PRIMARY KEY (HOST_ID);

ALTER TABLE airbnb.property ADD FOREIGN KEY (ROOM_TYPE) REFERENCES airbnb.room_type(ROOM_TYPE_ID);
ALTER TABLE airbnb.property ADD FOREIGN KEY (HOST_ID) REFERENCES airbnb.host(HOST_ID);
ALTER TABLE airbnb.order ADD FOREIGN KEY (PROPERTY_ID) REFERENCES airbnb.property(PROPERTY_ID);
ALTER TABLE airbnb.order ADD FOREIGN KEY (CUST_ID) REFERENCES airbnb.customer(CUST_ID);
ALTER TABLE airbnb.PAYMENT ADD FOREIGN KEY (ORDER_ID) REFERENCES airbnb.order(ORDER_ID);
ALTER TABLE airbnb.PAYMENT ADD FOREIGN KEY (PAYMENT_METHOD_ID) REFERENCES airbnb.PAYMENT_METHOD(PAYMENT_METHOD_ID);
ALTER TABLE airbnb.FEEDBACK ADD FOREIGN KEY (PROPERTY_ID) REFERENCES airbnb.PROPERTY(PROPERTY_ID);
ALTER TABLE airbnb.FEEDBACK ADD FOREIGN KEY (CUST_ID) REFERENCES airbnb.CUSTOMER(CUST_ID);
-- ALTER TABLE airbnb.property DROP FOREIGN KEY property_ibfk_2

INSERT INTO airbnb.order VALUES 
(155,'2021-6-10 00:00:00','2021-6-11 00:00:00','2021-6-17 00:00:00',1,18),
(156,'2021-6-11 00:00:00','2021-6-12 00:00:00','2022-6-17 00:00:00',2,19),
(157,'2021-6-12 00:00:00','2021-6-19 00:00:00','2021-6-28 00:00:00',2,22),
(158,'2021-12-25 00:00:00','2021-12-26 00:00:00','2022-12-27 00:00:00',3,23),
(159,'2021-12-26 00:00:00','2021-12-27 00:00:00','2021-12-31 00:00:00',3,5),
(160,'2021-12-27 00:00:00','2021-12-28 00:00:00','2022-12-30 00:00:00',4,33);

INSERT INTO airbnb.payment VALUES
(234048, '2021-06-10 00:00:00', 1, 678.89, 155),
(234044, '2021-06-11 00:00:00', 1, 212.05, 156),
(234040, '2021-06-12 00:00:00', 1, 765.98, 157),
(234036, '2021-12-25 00:00:00', 1, 347.98, 158),
(234032, '2021-12-26 00:00:00', 1, 435.78, 159),
(234028, '2021-12-27 00:00:00', 1, 287.78, 160);

INSERT INTO airbnb.feedback VALUES
(12367, 3.9, 18, 1),
(12368, 4.89, 19, 1),
(12369, 4.5, 22, 2),
(12370, 3.88, 23, 3),
(12371, 4.65, 5, 3),
(12372, 3.9, 33, 4);

-- Q1 What's the most popular room type? (-- with left JOIN)
SELECT type, count(property_id) AS count
FROM property
LEFT JOIN room_type
ON property.room_type = room_type.ROOM_TYPE_ID
GROUP BY room_type
ORDER BY count DESC;

-- Q2 What time of the year is there highest demand for airbnbs?  (-- without JOIN)
SELECT MONTH(order_date) AS MONTH, count(order_id) AS count
FROM airbnb.order
GROUP BY MONTH
ORDER BY count DESC;

-- Q3 What number of accommodations per property is most common?  (-- without JOIN)
SELECT ACCOMATION, count(property_id) AS count
FROM airbnb.property
GROUP BY ACCOMATION
ORDER BY count DESC;

-- Q4 What are the top 5 properties in the Bay Area?  (-- with LEFT JOIN)
SELECT p.property_id, p.name, o.order_id, count(*) AS count
FROM property p
LEFT JOIN airbnb.order o
ON p.property_id = o.property_id
GROUP BY p.property_id
ORDER BY count DESC
LIMIT 5;

-- Q5 Is payment method correlated with spend? (average, min, max amount per order from different types of payment methods) (-- with VIEW)
CREATE VIEW payment_paymethod AS
SELECT pm.method, p.AMOUNT, p.ORDER_ID
FROM payment p, payment_method pm
WHERE p.PAYMENT_METHOD_ID = pm.PAYMENT_METHOD_ID;

SELECT * FROM payment_paymethod;

SELECT method, 
       round(avg(amount),2) AS avg_amount, 
       round(min(amount),2) AS min_amount,
       round(max(amount),2) AS max_amount,
       count(order_id) AS order_num
FROM payment_paymethod
GROUP BY method;

-- Q6 Which properties have a review score lower than average review score? (with INNER JOIN, SUBQUERY)
SELECT p.name, f.review_score
FROM feedback f
JOIN property p
ON f.property_id = p.property_id
WHERE f.review_score < (SELECT AVG(review_score) FROM feedback) # avg_review score=4.374
ORDER BY f.review_score DESC;

-- Q7 Who made the orders just before holidays (Dec 19 to Dec 24, 2021)? (-- with INNER JOIN)
SELECT concat(c.CUST_FNAME,' ',c.CUST_LNAME) AS guest_name,
       o.ORDER_DATE,
       o.ORDER_START
FROM customer c
JOIN airbnb.order o
ON c.CUST_ID = o.CUST_ID
WHERE o.ORDER_DATE BETWEEN '2021-12-19 00:00:00' AND '2021-12-24 23:59:59';

-- Q8 What are the properties having highest review score, and who’s the host for that? (--with EQUI-JOIN, RANK)
SELECT p.name as property_name,
       f.REVIEW_SCORE,
       rank() OVER (ORDER BY f.REVIEW_SCORE DESC) AS review_rank, 
       h.HOST_NAME
FROM feedback f, property p, host h
WHERE p.PROPERTY_ID = f.PROPERTY_ID AND
      p.host_id = h.host_id
LIMIT 5;

-- Q9 What is the frequency of different review ratings? (-- with stored procedure for counting review score)
DELIMITER //
CREATE procedure Review_Score()
BEGIN
  SELECT FLOOR(review_score) AS rating, count(fbk_id) AS rating_num
  FROM feedback
  GROUP BY rating
  ORDER BY rating DESC;
END; //
CALL Review_Score();

-- Q10 Do properties with more amenities get higher ratings? (--with JOIN, SUBQUERY)
WITH amentities AS (
  SELECT parking,
         dishwasher,
         hot_tub,
         wifi, 
         (parking+dishwasher+hot_tub+wifi) AS total_amenities,
         property_id
  FROM property)
  SELECT a.total_amenities, 
         ROUND(AVG(f.review_score),2) AS avg_rating
  FROM amentities a
  JOIN feedback f
  ON a.property_id = f.property_id
  GROUP BY a.total_amenities
  ORDER BY 2 DESC;
