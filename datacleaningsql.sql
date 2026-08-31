SELECT *
FROM railways_uk.railway_messy;

-- creating a staging/working table so the data doesnot get messy
CREATE TABLE railway_staging
LIKE railway_messy;

SELECT *
FROM railway_staging;

INSERT railway_staging
SELECT * FROM
railway_messy;

WITH duplicates AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY 
`Transaction ID`,`Date of Purchase`,
`Time of Purchase`, `Purchase Type`,
 `Payment Method`,`Railcard`,
 `Ticket Class`,`Ticket Type`,Price,
 `Departure Station`,`Arrival Destination`,
 `Date of Journey`, `Departure Time`,
 `Arrival Time`, `Actual Arrival Time`,
 `Journey Status`, `Reason for Delay`,
 `Refund Request`) as row_num
FROM railway_staging

)
SELECT * FROM
duplicates
WHERE row_num >1
ORDER BY 1
;


WITH duplicates2 AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY 
`Transaction ID`
) as row_num
FROM railway_staging2
)
SELECT * FROM
duplicates2
WHERE row_num >1 
ORDER BY 1
;



SELECT *
FROM railway_staging
WHERE `Transaction ID` = 'ed24b1b1-1251-46d2-a0ce';

CREATE TABLE `railway_staging2` (
  `Transaction ID` text,
  `Date of Purchase` text,
  `Time of Purchase` text,
  `Purchase Type` text,
  `Payment Method` text,
  `Railcard` text,
  `Ticket Class` text,
  `Ticket Type` text,
  `Price` text,
  `Departure Station` text,
  `Arrival Destination` text,
  `Date of Journey` text,
  `Departure Time` text,
  `Arrival Time` text,
  `Actual Arrival Time` text,
  `Journey Status` text,
  `Reason for Delay` text,
  `Refund Request` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO railway_staging2
SELECT *,ROW_NUMBER() OVER(PARTITION BY 
`Transaction ID`
) as row_num
FROM railway_staging;

SELECT * 
FROM
railway_staging2
WHERE row_num >1 
;

UPDATE railway_staging2
SET `Transaction ID` = TRIM(`Transaction ID`)
;

SELECT one.`Transaction ID` as untrimmed , two.`Transaction ID` as trimmed
FROM railway_staging as one
JOIN railway_staging2 as two
ON one.`Transaction ID` = two.`Transaction ID` 
WHERE one.`Transaction ID` = two.`Transaction ID` 
;

SELECT * FROM
railway_staging2;

SELECT `Transaction ID` FROM
railway_staging3
WHERE `Transaction ID` NOT LIKE '________-____-%';


CREATE TABLE `railway_staging3` (
  `Transaction ID` text,
  `Date of Purchase` text,
  `Time of Purchase` text,
  `Purchase Type` text,
  `Payment Method` text,
  `Railcard` text,
  `Ticket Class` text,
  `Ticket Type` text,
  `Price` text,
  `Departure Station` text,
  `Arrival Destination` text,
  `Date of Journey` text,
  `Departure Time` text,
  `Arrival Time` text,
  `Actual Arrival Time` text,
  `Journey Status` text,
  `Reason for Delay` text,
  `Refund Request` text,
  `row_num` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM railway_staging3;

INSERT INTO railway_staging3
SELECT *
FROM railway_staging2; 

SELECT `Transaction ID` FROM
railway_staging3
WHERE `Transaction ID` LIKE '________-____-____-%';

-- updating the table to add - on the 19th position on the transaction ID
UPDATE railway_staging3
SET `Transaction ID` = INSERT(`Transaction ID`,19,0,'-')
WHERE `Transaction ID` IS NOT NULL AND `Transaction ID` NOT LIKE '________-____-____-%';


SELECT tbl1.`Transaction ID` as Table1 , tbl2.`Transaction ID` as Table2
FROM railway_staging3 as tbl1
JOIN railway_staging3 as tbl2
	ON tbl1.`Transaction ID` = tbl2.`Transaction ID`
WHERE NOT (BINARY tbl1.`Transaction ID` <=> tbl2.`Transaction ID`);

-- setting everything to a consistent lowercase values
UPDATE railway_staging3
SET `Transaction ID` = LOWER(`Transaction ID`);

-- removing duplicates from transaction

ALTER TABLE railway_staging3
DROP COLUMN row_num;

WITH duplicates3 AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY 
`Transaction ID`
) as row_num
FROM railway_staging4
)
SELECT * FROM
duplicates3
WHERE row_num >1 
ORDER BY 1
;

CREATE TABLE `railway_staging4` (
  `Transaction ID` text,
  `Date of Purchase` text,
  `Time of Purchase` text,
  `Purchase Type` text,
  `Payment Method` text,
  `Railcard` text,
  `Ticket Class` text,
  `Ticket Type` text,
  `Price` text,
  `Departure Station` text,
  `Arrival Destination` text,
  `Date of Journey` text,
  `Departure Time` text,
  `Arrival Time` text,
  `Actual Arrival Time` text,
  `Journey Status` text,
  `Reason for Delay` text,
  `Refund Request` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO railway_staging4
SELECT *,ROW_NUMBER() OVER(PARTITION BY 
`Transaction ID`
) as row_num
FROM railway_staging3;

SELECT * FROM
railway_staging4
;

SELECT *
FROM railway_staging4
WHERE `Transaction ID` = 'e8ffbd87-d257-4846-833b';

SELECT `Transaction ID`
FROM railway_staging4
ORDER BY 1
;


-- Transaction ID column Cleaned Properlt
 -- 2) Date of Purchase table cleaning 





SELECT `Date of Purchase`,STR_TO_DATE(`Date of Purchase`,'%m/%d/%Y')
FROM railway_staging4
WHERE STR_TO_DATE(`Date of Purchase`,'%m/%d/%Y') IS NOT NULL
ORDER BY 1
;


-- figure out an way to solve this Error Code: 1411. Incorrect datetime value: '02/16/2024' for function str_to_date


UPDATE railway_staging4
SET `Date of Purchase` = STR_TO_DATE(`Date of Purchase`,'%m/%d/%Y')
WHERE `Date of Purchase` REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4}' 
;

SELECT `Date of Purchase`,STR_TO_DATE(`Date of Purchase`,'%m/%d/%Y')
FROM railway_staging4
WHERE `Date of Purchase` = '2024-03-21' AND STR_TO_DATE(`Date of Purchase`,'%m/%d/%Y') IS NOT NULL
;

SELECT 
`Date of Purchase`, 
CASE 
    WHEN `Date of Purchase` REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN str_to_date(`Date of Purchase`, '%Y/%m/%d')
    ELSE 'Unmatched Format'
END as Conversion
From railway_staging4;
    
    
-- eg : 22/02/2024

SELECT `Date of Purchase` as original_string,
--                  22-02(Give everything before the 2nd -)    (now in{22-02} give everything after last -) so 02
CAST(substring_index(substring_index(`Date of Purchase`,'-', 2),'-',-1) AS unsigned) as second_section_value,
--  in 22-02-2024 give everything before the first '-' i.e 22
CAST(SUBSTRING_INDEX(`Date of Purchase`, '-', 1) AS UNSIGNED) AS first_section_value,
-- Now the value is obtained evaluate it
CASE 
	WHEN CAST(substring_index(substring_index(`Date of Purchase`,'-', 2),'-',-1) AS unsigned) BETWEEN 13 AND 31
    THEN 'Confirmed: Day(Format is MM-DD-YYYY Format)'
    WHEN CAST(substring_index(`Date of Purchase`, '-', 1) as unsigned) BETWEEN 13 AND 31
    THEN 'Confirmed: Day(Format is DD-MM-YYYY Format)'
    WHEN CAST(substring_index(substring_index(`Date of Purchase`,'-', 2),'-',-1) AS unsigned) BETWEEN 1 AND 12
    AND CAST(substring_index(`Date of Purchase`, '-', 1) as unsigned) BETWEEN 1 AND 12
    THEN 'Ambiguous (Under 12: Could be MM-DD or DD-MM)'
    ELSE `Date of Purchase`
End as valid_result
From railway_staging4
WHERE `Date of Purchase` REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}';
    
    
 
UPDATE railway_staging3
SET `Date of Purchase` = CASE
	WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date of Purchase`,'/',2),'/',-1) as UNSIGNED) BETWEEN 13 AND 31
		THEN DATE_FORMAT(STR_TO_DATE(`Date of Purchase`, '%m/%d/%Y'), '%Y-%m-%d')
    
    WHEN CAST(SUBSTRING_INDEX(`Date of Purchase`,'/',1) as unsigned) BETWEEN 13 AND 31
		THEN DATE_FORMAT(STR_TO_DATE(`Date of Purchase`, '%d/%m/%Y'),' %Y-%m-%d')
	 WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date of Purchase`, '/', 2), '/', -1) AS UNSIGNED) BETWEEN 1 AND 12
        THEN DATE_FORMAT(STR_TO_DATE(`Date of Purchase`, '%m/%d/%Y'), '%Y-%m-%d')

    ELSE `Date of Purchase`
END
WHERE `Date of Purchase` REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}';
    
    
UPDATE railway_staging4
SET `Date of Purchase` = CASE
	WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date of Purchase`,'-',2),'-',-1) as UNSIGNED) BETWEEN 13 AND 31
		THEN DATE_FORMAT(STR_TO_DATE(`Date of Purchase`, '%m-%d-%Y'), '%Y-%m-%d')
    
    WHEN CAST(SUBSTRING_INDEX(`Date of Purchase`,'-',1) as unsigned) BETWEEN 13 AND 31
		THEN DATE_FORMAT(STR_TO_DATE(`Date of Purchase`, '%d-%m-%Y'),' %Y-%m-%d')
	 WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date of Purchase`, '-', 2), '-', -1) AS UNSIGNED) BETWEEN 1 AND 12
        THEN DATE_FORMAT(STR_TO_DATE(`Date of Purchase`, '%m-%d-%Y'), '%Y-%m-%d')

    ELSE `Date of Purchase`
END
WHERE `Date of Purchase` REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}';


UPDATE railway_staging4
SET `Date of Purchase` = TRIM(`Date of Purchase`);

ALTER TABLE railway_staging4
MODIFY COLUMN `Date of Purchase` DATE;

SELECT *
FROM railway_staging3;

## Date section is cleaned properly

SELECT `Time of Purchase` 
FROM railway_staging4;


SELECT `Time of Purchase` 
FROM railway_staging4
WHERE `Time of Purchase` LIKE '%:% _M';


-- steps to change the entire time format
-- step 1 : changing the am/pm to proper 24 hr format

SELECT `Time of Purchase` as original_Time,
CAST(substring_index(`Time of Purchase`,':',1) as SIGNED)   as hour_time,
CAST(substring_index(substring_index(`Time of Purchase`,' ',1),':',-1) as SIGNED) as minute_time,
substring_index(`Time of Purchase`,' ',-1) as am_pm,
CASE 
		WHEN substring_index(`Time of Purchase`,' ',-1) LIKE 'AM' AND CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) != 12
        THEN CONCAT(CAST(substring_index(`Time of Purchase`,':',1) as SIGNED),":",CAST(substring_index(substring_index(`Time of Purchase`,' ',1),':',-1) as SIGNED))
       
        WHEN substring_index(`Time of Purchase`,' ',-1) LIKE 'AM' AND CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) = 12
        THEN CONCAT(00,":",CAST(substring_index(substring_index(`Time of Purchase`,' ',1),':',-1) as SIGNED))
        
        WHEN substring_index(`Time of Purchase`,' ',-1) LIKE 'PM' AND CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) != 12
        THEN CONCAT(CAST(substring_index(`Time of Purchase`,':',1) as SIGNED)+12 ,":",CAST(substring_index(substring_index(`Time of Purchase`,' ',1),':',-1) as SIGNED))
        
		WHEN substring_index(`Time of Purchase`,' ',-1) LIKE 'PM' AND CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) = 12
        THEN CONCAT(CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) ,":",CAST(substring_index(substring_index(`Time of Purchase`,' ',1),':',-1) as SIGNED))
END as proper_time
FROM railway_staging4
WHERE `Time of Purchase` REGEXP '[A-Z]{2}';










UPDATE railway_staging4
SET `Time of Purchase`=
	CASE
		WHEN substring_index(`Time of Purchase`,' ',-1) LIKE 'AM' AND CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) != 12
        THEN CONCAT(CAST(substring_index(`Time of Purchase`,':',1) as SIGNED),":",CAST(substring_index(substring_index(`Time of Purchase`,' ',1),':',-1) as SIGNED))
       
        WHEN substring_index(`Time of Purchase`,' ',-1) LIKE 'AM' AND CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) = 12
        THEN CONCAT(00,":",CAST(substring_index(substring_index(`Time of Purchase`,' ',1),':',-1) as SIGNED))
        
        WHEN substring_index(`Time of Purchase`,' ',-1) LIKE 'PM' AND CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) != 12
        THEN CONCAT(CAST(substring_index(`Time of Purchase`,':',1) as SIGNED)+12 ,":",CAST(substring_index(substring_index(`Time of Purchase`,' ',1),':',-1) as SIGNED))
        
		WHEN substring_index(`Time of Purchase`,' ',-1) LIKE 'PM' AND CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) = 12
        THEN CONCAT(CAST(substring_index(`Time of Purchase`,':',1) as SIGNED) ,":",CAST(substring_index(substring_index(`Time of Purchase`,' ',1),':',-1) as SIGNED))
        ELSE `Time of Purchase`
	END
WHERE `Time of Purchase` REGEXP '[A-Z]{2}';


SELECT `Time of Purchase`
FROM railway_staging4
WHERE substring_index(`Time of Purchase`,' ',-1) LIKE '_M' 
;

SELECT CAST(('0:25') as TIME);


SELECT `Time of Purchase`,CAST((`Time of Purchase`) as TIME)
FROM railway_staging4;


START TRANSACTION;
UPDATE railway_staging4
SET `Time of Purchase` = CAST((`Time of Purchase`) as TIME)
WHERE `Time of Purchase` IS NOT NULL;
COMMIT;

SELECT * FROM
railway_staging4;

-- Time update complete


SELECT `Purchase Type`
FROM railway_staging4;

UPDATE railway_staging4
SET `Purchase Type` = TRIM(`Purchase Type`);

SELECT `Purchase Type`,SUBSTRING(`Purchase Type`,1,1),CONCAT(UPPER(SUBSTRING(`Purchase Type`,1,1)),SUBSTRING(`Purchase Type`,2))
FROM railway_staging4;


UPDATE railway_staging4
SET `Purchase Type` = LOWER(`Purchase Type`);

UPDATE railway_staging3
SET `Purchase Type` = CONCAT(UPPER(SUBSTRING(`Purchase Type`,1,1)),SUBSTRING(`Purchase Type`,2));

-- Purchase Type Cleaned
-- to bybass caseinsensitve case in sql
SELECT DISTINCT `Payment Method` COLLATE utf8mb4_bin
FROM railway_staging4;

UPDATE railway_staging4
SET `Payment Method` = TRIM(`Payment Method`)
;

UPDATE railway_staging4
SET `Payment Method` = LOWER(`Payment Method`);

SELECT DISTINCT `Payment Method`
FROM railway_staging4
WHERE `Payment Method` LIKE 'debit%'
;


UPDATE railway_staging4
SET `Payment Method` = 'Debit Card' 
WHERE `Payment Method` LIKE 'debit%';

SELECT DISTINCT `Payment Method`
FROM railway_staging4
WHERE `Payment Method` LIKE 'credit%'
;

UPDATE railway_staging4
SET `Payment Method` = 'Credit Card' 
WHERE `Payment Method` LIKE 'Credit%';

SELECT DISTINCT `Payment Method`
FROM railway_staging4
WHERE `Payment Method` LIKE 'cont%'
;

UPDATE railway_staging4
SET `Payment Method` = 'Contactless' 
WHERE `Payment Method` LIKE 'cont%';

SELECT * 
FROM railway_staging4
WHERE `Payment Method` = 'cc';
;

UPDATE railway_staging4
SET `Payment Method` = 'Cash Credit' 
WHERE `Payment Method` = 'cc';

SELECT * 
FROM railway_staging4
WHERE `Payment Method` = '';
;

UPDATE railway_staging4
SET `Payment Method` = 'n/a' 
WHERE `Payment Method` = 'none';

SELECT DISTINCT `Payment Method`
FROM railway_staging4
WHERE `Transaction ID` = 'a0759111-0bf1-4c72-86d5';

-- payment method cleaned

SELECT DISTINCT Railcard COLLATE utf8mb4_bin 
FROM
railway_staging4;

UPDATE railway_staging3
SET Railcard = LOWER(`Railcard`);

SELECT Railcard
FROM railway_staging4
WHERE Railcard = 'Senior';

UPDATE railway_staging4
SET Railcard = 'n/a'
WHERE Railcard = '-';

UPDATE railway_staging4
SET Railcard = 'Senior'
WHERE Railcard = 'senior';

SELECT Railcard, Substring(`Railcard`,1,1),Substring(`Railcard`,2),CONCAT(UPPER(Substring(`Railcard`,1,1)),Substring(`Railcard`,2))
FROM railway_staging4
WHERE Railcard != 'n/a';

UPDATE railway_staging4
SET Railcard = CONCAT(UPPER(Substring(`Railcard`,1,1)),Substring(`Railcard`,2))
WHERE Railcard != 'n/a';


-- Railcard section cleaned

SELECT DISTINCT `Ticket Class` COLLATE utf8mb4_bin
FROM railway_staging3;

UPDATE railway_staging4
SET `Ticket Class` = TRIM(`Ticket Class`);

SELECT `Ticket Class` 
FROM railway_staging4
WHERE `Ticket Class` Like 'ST%';

UPDATE railway_staging4
SET `Ticket Class` = 'Standard'
WHERE `Ticket Class` Like 'ST%';

-- Ticket class complete

SELECT DISTINCT `Ticket Type` COLLATE utf8mb4_bin
FROM railway_staging4;

WITH trimmed as
( SELECT DISTINCT `Ticket Type` COLLATE utf8mb4_bin as lowerthis
	FROM railway_staging3
)
SELECT lowerthis, lower(lowerthis)
FROM trimmed;

UPDATE railway_staging3
SET `Ticket Type` = TRIM(`Ticket Type`);

UPDATE railway_staging4
SET `Ticket Type` = LOWER(`Ticket Type`);

SELECT `Ticket Type`
FROM railway_staging4
WHERE `Ticket Type` = 'off-peak';

UPDATE railway_staging4
SET `Ticket Type` = 'Off-Peak'
WHERE `Ticket Type` = 'off-peak';


-- Ticket Type clear

SELECT DISTINCT Price COLLATE utf8mb4_bin
FROM railway_staging4
WHERE Price NOT REGEXP '^[0-9]'
;

SELECT *
FROM railway_staging4
WHERE Price is NULL;


UPDATE railway_staging4
SET Price = 'n/a'
WHERE Price NOT REGEXP '[0-9]';

UPDATE railway_staging4
SET Price = 0
WHERE Price = 'n/a';

UPDATE railway_staging4
SET Price = TRIM(Price);


-- remove extra character from price
SELECT DISTINCT Price COLLATE utf8mb4_bin, ROW_NUMBER() OVER()
FROM railway_staging3
WHERE Price LIKE '%Â£%'
;

SELECT Price,SUBSTRING(Price,1,2),SUBSTRING(Price,3)
FROM railway_staging4
WHERE Price LIKE '%Â£%'
;

UPDATE railway_staging4
SET Price = SUBSTRING(Price,3)
WHERE Price LIKE '%Â£%'
;

SELECT Price,SUBSTRING_INDEX(Price," ",1),SUBSTRING_INDEX(Price," ",-1)
FROM railway_staging4
WHERE Price LIKE '%GBP%'
;

UPDATE railway_staging4
SET Price = SUBSTRING_INDEX(Price," ",1)
WHERE Price LIKE '%GBP%'
;

SELECT Price,Row_Number() Over()
FROM railway_staging4
WHERE Price REGEXP '^[0-9]'
;
SELECT Price,Row_Number() Over()
FROM railway_staging4
WHERE Price REGEXP '^-[0-9]'
;
SELECT Price,Row_Number() Over()
FROM railway_staging4
WHERE Price = 'n/a'
;

START TRANSACTION;

UPDATE railway_staging4
SET Price = CAST(Round(Price) AS UNSIGNED)
;

ROLLBACK;

SELECT DISTINCT Price COLLATE utf8mb4_bin , ROW_NUMBER() OVER()
FROM railway_staging3;

UPDATE railway_staging4
SET Price = 'n/a'
WHERE Price > 1000000;


-- conver price to integer


DESCRIBE railway_staging3;


SELECT *
FROM railway_staging4
;

ALTER TABLE railway_staging4
MODIFY COLUMN Price DECIMAL(10,2);

ALTER TABLE railway_staging4
RENAME COLUMN Price TO `Price(GBP)`;

UPDATE railway_staging4
SET `Price(GBP)` = NULL
WHERE `Price(GBP)` = 0;

-- Price section complete NULL values are unknown comeback to this when all the data is cleaned



UPDATE railway_staging4
SET `Departure Station` = TRIM(`Departure Station`);

UPDATE railway_staging4
SET `Departure Station` = LOWER(`Departure Station`);

SELECT `Departure Station`,Upper(SUBSTRING(`Departure Station`,1,1)),SUBSTRING(`Departure Station`,2),CONCAT(Upper(SUBSTRING(`Departure Station`,1,1)),SUBSTRING(`Departure Station`,2))
FROM railway_staging4;

UPDATE railway_staging4
SET `Departure Station` = CONCAT(Upper(SUBSTRING(`Departure Station`,1,1)),SUBSTRING(`Departure Station`,2));

UPDATE railway_staging4
SET `Departure Station` = 'Edinburgh Waverley'
WHERE `Departure Station` = 'Edinburgh waverley'
;

SELECT DISTINCT `Departure Station` COLLATE utf8mb4_bin
FROM railway_staging4;

SELECT * FROM 
railway_staging3;

WITH duplicates3 AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY 
`Transaction ID`
) as row_num
FROM railway_staging3
)
SELECT * FROM
duplicates3
;


SELECT *
FROM railway_staging3;


CREATE TABLE `railway_staging5` (
  `Transaction ID` text,
  `Date of Purchase` date DEFAULT NULL,
  `Time of Purchase` text,
  `Purchase Type` text,
  `Payment Method` text,
  `Railcard` text,
  `Ticket Class` text,
  `Ticket Type` text,
  `Price(GBP)` decimal(10,2) DEFAULT NULL,
  `Departure Station` text,
  `Arrival Destination` text,
  `Date of Journey` text,
  `Departure Time` text,
  `Arrival Time` text,
  `Actual Arrival Time` text,
  `Journey Status` text,
  `Reason for Delay` text,
  `Refund Request` text,
  `row_num` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM railway_staging3;

INSERT INTO railway_staging5
SELECT * FROM railway_staging3;

-- railway station 5 is the latest one

SELECT DISTINCT `Departure Station` COLLATE utf8mb4_bin
FROM railway_staging5; 


START TRANSACTION;
UPDATE railway_staging5
SET `Departure Station` = 'Manchester Piccadilly'
WHERE `Departure Station` = 'Manchester Piccadilly Piccadilly';

UPDATE railway_staging5
SET `Departure Station` = 'London Paddington'
WHERE `Departure Station` = 'London Paddington Paddington';

UPDATE railway_staging5
SET `Departure Station` = 'London Euston'
WHERE `Departure Station` ='London Euston Euston';

UPDATE railway_staging5
SET `Departure Station` = 'Oxford'
WHERE `Departure Station` = 'Oxford Oxford Oxford';

UPDATE railway_staging5
SET `Departure Station` = 'York'
WHERE `Departure Station` = 'York York York';

UPDATE railway_staging5
SET `Departure Station` = 'Reading'
WHERE `Departure Station` = 'Reading Reading Reading';

UPDATE railway_staging5
SET `Departure Station` = 'Edinburgh Waverley'
WHERE `Departure Station` = 'Edinburgh Waverley Waverley';


ROLLBACK;

COMMIT;

-- DEPARTURE STATION COMPLETE

SELECT *
FROM railway_staging5;

SELECT DISTINCT `Arrival Destination` COLLATE utf8mb4_bin
FROM railway_staging3;

START TRANSACTION;
UPDATE railway_staging5
set `Arrival Destination` = TRIM(`Arrival Destination`);

UPDATE railway_staging5
set `Arrival Destination` = LOWER(`Arrival Destination`);

ROLLBACK;

COMMIT;


-- from here hasnot been done for railstaging 5 yet

SELECT `Arrival Destination`,Upper(LEFT(`Arrival Destination`,1)),Substring(`Arrival Destination`,2),
Concat(Upper(LEFT(`Arrival Destination`,1)),Substring(`Arrival Destination`,2))
FROM railway_staging5;

START TRANSACTION;
UPDATE railway_staging5
SET `Arrival Destination` = Concat(Upper(LEFT(`Arrival Destination`,1)),Substring(`Arrival Destination`,2))
;

COMMIT;

SELECT DISTINCT `Arrival Destination` COLLATE utf8mb4_bin
FROM railway_staging5
WHERE length(`Arrival Destination`) >10 
and `Arrival Destination` != 'Wolverhampton' 
and `Arrival Destination` != 'Peterborough'
and `Arrival Destination` != 'Birmingham new street'
and `Arrival Destination` != 'Liverpool lime street'
and `Arrival Destination` != 'Bristol temple meads'
and `Arrival Destination` != 'London st pancras'
and `Arrival Destination` != 'London kings cross'
;



SELECT `Arrival Destination`,substring_index(substring_index(`Arrival Destination`," ",2)," ",-1) as 2ndword
,Upper(LEFT(substring_index(substring_index(`Arrival Destination`," ",2)," ",-1),1)) as 1stlet2ndword
,substring(substring_index(substring_index(`Arrival Destination`," ",2)," ",-1),2) as rest_letters,
concat(substring_index(`Arrival Destination`," ",1)," ",Upper(LEFT(substring_index(substring_index(`Arrival Destination`," ",2)," ",-1),1))
,substring(substring_index(substring_index(`Arrival Destination`," ",2)," ",-1),2)) as result
FROM railway_staging5
WHERE length(`Arrival Destination`) >10 
and `Arrival Destination` != 'Wolverhampton' 
and `Arrival Destination` != 'Peterborough'
and `Arrival Destination` != 'Birmingham new street'
and `Arrival Destination` != 'Liverpool lime street'
and `Arrival Destination` != 'Bristol temple meads'
and `Arrival Destination` != 'London st pancras'
and `Arrival Destination` != 'London kings cross'
;

START TRANSACTION;
UPDATE railway_staging5
set `Arrival Destination` = concat(substring_index(`Arrival Destination`," ",1)," ",Upper(LEFT(substring_index(substring_index(`Arrival Destination`," ",2)," ",-1),1))
,substring(substring_index(substring_index(`Arrival Destination`," ",2)," ",-1),2))
WHERE length(`Arrival Destination`) >10 
and `Arrival Destination` != 'Wolverhampton' 
and `Arrival Destination` != 'Peterborough'
and `Arrival Destination` != 'Birmingham new street'
and `Arrival Destination` != 'Liverpool lime street'
and `Arrival Destination` != 'Bristol temple meads'
and `Arrival Destination` != 'London st pancras'
and `Arrival Destination` != 'London kings cross'
;

COMMIT;
ROLLBACK;

SELECT DISTINCT `Arrival Destination` COLLATE utf8mb4_bin
FROM railway_staging5
;


START TRANSACTION;
UPDATE railway_staging5
SET `Arrival Destination` = 'Birmingham New Street'
WHERE `Arrival Destination` = 'Birmingham new street';

UPDATE railway_staging5
SET `Arrival Destination` = 'Liverpool Lime Street'
WHERE `Arrival Destination` = 'Liverpool lime street';

UPDATE railway_staging5
SET `Arrival Destination` = 'Bristol Temple Meads'
WHERE `Arrival Destination` = 'Bristol temple meads';


UPDATE railway_staging5
SET `Arrival Destination` = 'London St Pancras'
WHERE `Arrival Destination` = 'London st pancras';

UPDATE railway_staging5
SET `Arrival Destination` = 'London Kings Cross'
WHERE `Arrival Destination` = 'London kings cross';

ROLLBACK;

COMMIT;


-- ARRIVAL DESTINATION CLEANED

SELECT `Date of Journey`
FROM railway_staging3;


SELECT `Date of Journey`,str_to_date(`Date of Journey`,'%d-%m-%Y')
FROM railway_staging5
WHERE `Date of Journey` LIKE '%-%-____'
;

START TRANSACTION;

UPDATE railway_staging5
set `Date of Journey` = str_to_date(`Date of Journey`,'%d-%m-%Y')
WHERE `Date of Journey` LIKE '%-%-____';

ROLLBACK;

COMMIT;



SELECT `Date of Journey` as original_string,
--                  22-02(Give everything before the 2nd -)    (now in{22-02} give everything after last -) so 02
CAST(substring_index(substring_index(`Date of Journey`,'/', 2),'/',-1) AS unsigned) as second_section_value,
--  in 22-02-2024 give everything before the first '-' i.e 22
CAST(SUBSTRING_INDEX(`Date of Journey`, '/', 1) AS UNSIGNED) AS first_section_value,
-- Now the value is obtained evaluate it
CASE 
	WHEN CAST(substring_index(substring_index(`Date of Journey`,'/', 2),'/',-1) AS unsigned) BETWEEN 13 AND 31
    THEN 'Confirmed: Day(Format is MM/DD/YYYY Format)'
    
    WHEN CAST(substring_index(`Date of Journey`, '/', 1) as unsigned) BETWEEN 13 AND 31
    THEN 'Confirmed: Day(Format is DD/MM/YYYY Format)'
    
    WHEN CAST(substring_index(substring_index(`Date of Journey`,'/', 2),'/',-1) AS unsigned) BETWEEN 1 AND 12
    AND CAST(substring_index(`Date of Journey`, '/', 1) as unsigned) BETWEEN 1 AND 12
    THEN 'Ambiguous (Under 12: Could be MM/DD or DD/MM)'
    
    ELSE `Date of Journey`
End as valid_result
From railway_staging5
WHERE `Date of Journey` REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}';
    
    
START TRANSACTION;
UPDATE railway_staging5
SET `Date of Journey` = CASE
	WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date of Journey`,'/',2),'/',-1) as UNSIGNED) BETWEEN 13 AND 31
		THEN DATE_FORMAT(STR_TO_DATE(`Date of Journey`, '%m/%d/%Y'), '%Y-%m-%d')
    
    WHEN CAST(SUBSTRING_INDEX(`Date of Journey`,'/',1) as unsigned) BETWEEN 13 AND 31
		THEN DATE_FORMAT(STR_TO_DATE(`Date of Journey`, '%d/%m/%Y'),' %Y-%m-%d')
        
	 WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(`Date of Journey`, '/', 2), '/', -1) AS UNSIGNED) BETWEEN 1 AND 12
        THEN DATE_FORMAT(STR_TO_DATE(`Date of Journey`, '%d/%m/%Y'), '%Y-%m-%d')

    ELSE `Date of Journey`
END
WHERE `Date of Journey` REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}';

UPDATE railway_staging5
SET `Date of Journey` = TRIM(`Date of Journey`);


ROLLBACK;

COMMIT;

SELECT `Date of Journey`
FROM railway_staging5
WHERE `Date of Journey` NOT LIKE '____-__-__';

START TRANSACTION;

ALTER TABLE railway_staging5
MODIFY COLUMN `Date of Journey` DATE;
ROLLBACK;
COMMIT;

-- DATE OF JOURNEY COMPLETE

SELECT DISTINCT `Departure Time`
FROM railway_staging5
;




-- Departure Time, Arrival Time and Actual Arrival time


SELECT DISTINCT `Actual Arrival Time`
FROM railway_staging5;

SELECT * FROM
railway_staging5;
COMMIT;

## START TRANSACTION;
## ALTER TABLE railway_staging3
## RENAME COLUMN `Arrival Time Temporary` TO `Arrival Time`;

## ALTER TABLE railway_staging3
## RENAME COLUMN `Arrival Time` TO `Actual Arrival Time`;





SELECT `Arrival Time`
FROM railway_staging5
WHERE `Arrival Time` LIKE '% _M'
;


SELECT `Arrival Time`
FROM railway_staging5
WHERE `Arrival Time` LIKE ' %'
;



SELECT `Arrival Time` as original_Time,
CAST(substring_index(`Arrival Time`,':',1) as SIGNED)   as hour_time,
CAST(substring_index(substring_index(`Arrival Time`,' ',1),':',-1) as SIGNED) as minute_time,
substring_index(`Arrival Time`,' ',-1) as am_pm,
CASE 
		WHEN substring_index(`Arrival Time`,' ',-1) LIKE 'AM' AND CAST(substring_index(`Arrival Time`,':',1) as SIGNED) != 12
        THEN CONCAT(CAST(substring_index(`Arrival Time`,':',1) as SIGNED),":",CAST(substring_index(substring_index(`Arrival Time`,' ',1),':',-1) as SIGNED))
       
        WHEN substring_index(`Arrival Time`,' ',-1) LIKE 'AM' AND CAST(substring_index(`Arrival Time`,':',1) as SIGNED) = 12
        THEN CONCAT(00,":",CAST(substring_index(substring_index(`Arrival Time`,' ',1),':',-1) as SIGNED))
        
        WHEN substring_index(`Arrival Time`,' ',-1) LIKE 'PM' AND CAST(substring_index(`Arrival Time`,':',1) as SIGNED) != 12
        THEN CONCAT(CAST(substring_index(`Arrival Time`,':',1) as SIGNED)+12 ,":",CAST(substring_index(substring_index(`Arrival Time`,' ',1),':',-1) as SIGNED))
        
		WHEN substring_index(`Arrival Time`,' ',-1) LIKE 'PM' AND CAST(substring_index(`Arrival Time`,':',1) as SIGNED) = 12
        THEN CONCAT(CAST(substring_index(`Arrival Time`,':',1) as SIGNED) ,":",CAST(substring_index(substring_index(`Arrival Time`,' ',1),':',-1) as SIGNED))
END as proper_time
FROM railway_staging5
WHERE `Arrival Time` REGEXP '[A-Z]{2}';




START TRANSACTION;

UPDATE railway_staging5
SET `Arrival Time`=
	CASE
		WHEN substring_index(`Arrival Time`,' ',-1) LIKE 'AM' AND CAST(substring_index(`Arrival Time`,':',1) as SIGNED) != 12
        THEN CONCAT(CAST(substring_index(`Arrival Time`,':',1) as SIGNED),":",CAST(substring_index(substring_index(`Arrival Time`,' ',1),':',-1) as SIGNED))
       
        WHEN substring_index(`Arrival Time`,' ',-1) LIKE 'AM' AND CAST(substring_index(`Arrival Time`,':',1) as SIGNED) = 12
        THEN CONCAT(00,":",CAST(substring_index(substring_index(`Arrival Time`,' ',1),':',-1) as SIGNED))
        
        WHEN substring_index(`Arrival Time`,' ',-1) LIKE 'PM' AND CAST(substring_index(`Arrival Time`,':',1) as SIGNED) != 12
        THEN CONCAT(CAST(substring_index(`Arrival Time`,':',1) as SIGNED)+12 ,":",CAST(substring_index(substring_index(`Arrival Time`,' ',1),':',-1) as SIGNED))
        
		WHEN substring_index(`Arrival Time`,' ',-1) LIKE 'PM' AND CAST(substring_index(`Arrival Time`,':',1) as SIGNED) = 12
        THEN CONCAT(CAST(substring_index(`Arrival Time`,':',1) as SIGNED) ,":",CAST(substring_index(substring_index(`Arrival Time`,' ',1),':',-1) as SIGNED))
        ELSE `Arrival Time`
	END
WHERE `Arrival Time` REGEXP '[A-Z]{2}';


ROLLBACK;

COMMIT;

SELECT `Arrival Time`
FROM railway_staging5
WHERE substring_index(`Arrival Time`,' ',-1) LIKE '_M' 
;

SELECT `Arrival Time`,CAST((`Arrival Time`) as TIME)
FROM railway_staging5;


START TRANSACTION;
UPDATE railway_staging5
SET `Arrival Time` = CAST((`Arrival Time`) as TIME)
WHERE `Arrival Time`IS NOT NULL;
COMMIT;

UPDATE railway_staging5
SET `Arrival Time` = NULL
WHERE `Arrival Time` = 'None';

SELECT *
FROM railway_staging5
WHERE `Arrival Time` = 'None';

SELECT DISTINCT `Arrival Time`
FROM railway_staging5;


START TRANSACTION;
ALTER TABLE railway_staging5
MODIFY COLUMN `Arrival Time` TIME;
COMMIT;

-- Departure time and Arrival time and Actual Arrival time cleaned



-- Journey Status

SELECT DISTINCT `Journey Status`
FROM railway_staging3;

SELECT DISTINCT `Journey Status`
FROM railway_staging5;

SELECT `Journey Status`
FROM railway_staging5;

START TRANSACTION;
UPDATE railway_staging5 
SET `Journey Status` = TRIM(`Journey Status`);

UPDATE railway_staging5
SET `Journey Status` = Lower(`Journey Status`);
ROLLBACK;

UPDATE railway_staging5
SET `Journey Status` = CONCAT(upper(Left(`Journey Status`,1)),substring(`Journey Status`,2));

UPDATE railway_staging5
SET `Journey Status` = 'On-Time'
WHERE `Journey Status` LIKE 'On%';

UPDATE railway_staging5
SET `Journey Status` = 'Delayed'
WHERE `Journey Status` LIKE 'De%';

UPDATE railway_staging3
SET `Journey Status` = 'Cancelled'
WHERE `Journey Status` LIKE 'C%';


commit;

SELECT `Journey Status`, Left(`Journey Status`,1),substring(`Journey Status`,2),CONCAT(upper(Left(`Journey Status`,1)),substring(`Journey Status`,2))
FROM railway_staging5;

SELECT `Journey Status`
FROM railway_staging5
WHERE `Journey Status` LIKE 'On%';

SELECT `Journey Status`
FROM railway_staging5
WHERE `Journey Status` LIKE 'De%';

SELECT `Journey Status`
FROM railway_staging3
WHERE `Journey Status` LIKE 'C%';

SELECT DISTINCT `Journey Status` FROM
railway_staging5;
-- Journey status cleaned

Select *
from railway_staging3;

SELECT DISTINCT `Reason for Delay` COLLATE utf8mb4_bin
FROM railway_staging3;

SELECT DISTINCT `Reason for Delay` COLLATE utf8mb4_bin
FROM railway_staging5;

SELECT `Reason for Delay` 
FROM railway_staging5
WHERE `Reason for Delay` LIKE 'technical issue';


SELECT `Reason for Delay` 
FROM railway_staging3
WHERE `Reason for Delay` LIKE 'N%';

SELECT `Reason for Delay` 
FROM railway_staging5
WHERE `Reason for Delay` LIKE 'N%';

SELECT `Reason for Delay` 
FROM railway_staging3
WHERE `Reason for Delay` LIKE '';

SELECT `Reason for Delay` 
FROM railway_staging5
WHERE `Reason for Delay` LIKE '';

SELECT `Reason for Delay` 
FROM railway_staging3
WHERE `Reason for Delay` LIKE '-';


SELECT `Reason for Delay` 
FROM railway_staging5
WHERE `Reason for Delay` LIKE '-';



SELECT `Reason for Delay`,
upper(left(`Reason for Delay`,1)),substring(substring_index(`Reason for Delay`," ",1),2) as 1st ,upper(left(substring_index(substring_index(`Reason for Delay`," ",2)," ",-1),1)) as 2nd ,
substring(substring_index(substring_index(`Reason for Delay`," ",2)," ",-1),2) as 3rd, concat(upper(left(`Reason for Delay`,1)),substring(substring_index(`Reason for Delay`," ",1),2)," ",upper(left(substring_index(substring_index(`Reason for Delay`," ",2)," ",-1),1)),
substring(substring_index(substring_index(`Reason for Delay`," ",2)," ",-1),2)) as output
FROM railway_staging3
WHERE
`Reason For Delay` = 'signal failure' or
`Reason For Delay` = 'technical issue'
;

SELECT `Reason for Delay`
FROM railway_staging3
WHERE `Reason for Delay` like 'weath%';

SELECT `Reason for Delay`
FROM railway_staging3
WHERE `Reason for Delay` like 'staf%';

SELECT `Reason for Delay`
FROM railway_staging3
WHERE `Reason for Delay` ='traffic';

START TRANSACTION;
UPDATE railway_staging3
SET `Reason for Delay` = TRIM(`Reason for Delay`);

UPDATE railway_staging3
SET `Reason for Delay` = NULL
WHERE `Reason for Delay` LIKE 'n%';

UPDATE railway_staging3
SET `Reason for Delay` = NULL
WHERE `Reason for Delay` LIKE '';

UPDATE railway_staging3
SET `Reason for Delay` = NULL
WHERE `Reason for Delay` LIKE '-';

UPDATE railway_staging3
SET `Reason for Delay` = 'Weather'
WHERE `Reason for Delay` like 'weath%';

UPDATE railway_staging3
SET `Reason for Delay` = 'Staff Shortage'
WHERE `Reason for Delay` like 'staf%';

UPDATE railway_staging3
SET `Reason for Delay` = 'Traffic'
WHERE `Reason for Delay` like 'traffic%';

UPDATE railway_staging3
SET `Reason for Delay` = concat(upper(left(`Reason for Delay`,1)),substring(substring_index(`Reason for Delay`," ",1),2)," ",upper(left(substring_index(substring_index(`Reason for Delay`," ",2)," ",-1),1)),
substring(substring_index(substring_index(`Reason for Delay`," ",2)," ",-1),2))
WHERE
`Reason For Delay` = 'signal failure' or
`Reason For Delay` = 'technical issue';


UPDATE railway_staging3
SET `Reason for Delay` = Lower(`Reason for Delay`);

ROLLBACK;

START TRANSACTION;
UPDATE railway_staging5
SET `Reason for Delay` = TRIM(`Reason for Delay`);

UPDATE railway_staging5
SET `Reason for Delay` = NULL
WHERE `Reason for Delay` LIKE 'n%';

UPDATE railway_staging5
SET `Reason for Delay` = NULL
WHERE `Reason for Delay` LIKE '';

UPDATE railway_staging5
SET `Reason for Delay` = NULL
WHERE `Reason for Delay` LIKE '-';

UPDATE railway_staging5
SET `Reason for Delay` = Lower(`Reason for Delay`);

UPDATE railway_staging5
SET `Reason for Delay` = 'Weather'
WHERE `Reason for Delay` like 'weath%';

UPDATE railway_staging5
SET `Reason for Delay` = 'Staff Shortage'
WHERE `Reason for Delay` like 'staf%';

UPDATE railway_staging5
SET `Reason for Delay` = 'Traffic'
WHERE `Reason for Delay` like 'traffic%';

UPDATE railway_staging5
SET `Reason for Delay` = concat(upper(left(`Reason for Delay`,1)),substring(substring_index(`Reason for Delay`," ",1),2)," ",upper(left(substring_index(substring_index(`Reason for Delay`," ",2)," ",-1),1)),
substring(substring_index(substring_index(`Reason for Delay`," ",2)," ",-1),2))
WHERE
`Reason For Delay` = 'signal failure' or
`Reason For Delay` = 'technical issue';

UPDATE railway_staging5
SET `Reason for Delay` = 'Unknown'
WHERE `Journey Status` = 'Cancelled'
and `Reason for delay` is null;


COMMIT;


-- some inconsitencies betwn journey status and reason for delay
SELECT `Reason for delay`
FROM 
railway_staging5
WHERE `Journey Status` != 'On-Time'
and `Reason for delay` is NULL
;


select DISTINCT `Reason for Delay`
FROM railway_staging3;


-- Reason for delay cleaned

SELECT * 
FROM railway_staging3;

-- REFUND REQUEST
SELECT DISTINCT `Refund Request` COLLATE utf8mb4_bin
FROM railway_staging5;

SELECT `Refund Request`
FROM railway_staging5
WHERE `Refund Request` LIKE 'y%';

SELECT `Refund Request`
FROM railway_staging5
WHERE `Refund Request` LIKE 'T%';

SELECT `Refund Request`
FROM railway_staging5
WHERE `Refund Request` LIKE '';

SELECT `Refund Request`
FROM railway_staging5
WHERE `Refund Request` IS NULL
;



START TRANSACTION;
UPDATE railway_staging5
SET `Refund Request` = 1
WHERE `Refund Request` LIKE 'y%';

UPDATE railway_staging5
SET `Refund Request` = 1
WHERE `Refund Request` LIKE 'T%';

UPDATE railway_staging5
SET `Refund Request` = NULL
WHERE `Refund Request` LIKE 'n/a';

UPDATE railway_staging3
SET `Refund Request` = NULL
WHERE `Refund Request` LIKE 'None';

UPDATE railway_staging5
SET `Refund Request` = NULL
WHERE `Refund Request` LIKE '-';

UPDATE railway_staging5
SET `Refund Request` = NULL
WHERE `Refund Request` LIKE '';

UPDATE railway_staging5
SET `Refund Request` = 0
WHERE `Refund Request` is not NULL
AND `Refund Request` != "1";

ROLLBACK;
COMMIT;


ALTER TABLE railway_staging5
MODIFY COLUMN `Refund Request` BOOLEAN;



SELECT * FROM 
railway_staging5
WHERE `Journey Status` = 'Delayed'
AND `Refund Request` is NULL;
;


-- Refund Request cleaned completed
-- SOME INCONSISTENCIES fix
START TRANSACTION;

UPDATE railway_staging5
SET `Actual Arrival Time` = `Arrival Time`
WHERE `Actual Arrival Time` IS NULL
AND `Journey Status` = 'On-Time';

SELECT `Arrival Time`,`Actual Arrival Time`,`Journey Status`
FROM railway_staging3
WHERE `Actual Arrival Time` IS NULL
AND `Journey Status` = 'Cancelled';

COMMIT;

SELECT *
FROM railway_staging5
WHERE 
 `Price(GBP)` >100 and 
-- `Ticket Class` = 'First class' and
`Departure Station` = 'Liverpool Lime Street' and
`Arrival Destination` = 'London Euston'
 ;
 
 SELECT `Purchase Type`, `Railcard` ,`Ticket Class`,`Ticket Type`,`Price(GBP)`,`Departure Station`,`Arrival Destination`,ROW_NUMBER() OVER(Partition By `Departure Station`)
 FROM railway_staging5
 WHERE `Price(GBP)` > 1000
 ;
 
 

 

 

 
 


















-- need to update null and missing values










DROP TABLE `railway_final_table` ;
CREATE TABLE `railway_final_table` (
  `Transaction ID` text,
  `Date of Purchase` date DEFAULT NULL,
  `Time of Purchase` time DEFAULT NULL,
  `Purchase Type` text,
  `Payment Method` text,
  `Railcard` text,
  `Ticket Class` text,
  `Ticket Type` text,
  `Price(GBP)` decimal(10,2) DEFAULT NULL,
  `Departure Station` text,
  `Arrival Destination` text,
  `Date of Journey` date DEFAULT NULL,
  `Departure Time` time DEFAULT NULL,
  `Arrival Time` time DEFAULT NULL,
  `Actual Arrival Time` time DEFAULT NULL,
  `Journey Status` text,
  `Reason for Delay` text,
  `Refund Request` tinyint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO railway_final_table
SELECT * FROM railway_staging5;

SELECT *
FROM railway_final_table;


 SELECT `Purchase Type`, `Railcard` ,`Ticket Class`,`Ticket Type`,`Price(GBP)`,`Departure Station`,`Arrival Destination`,ROW_NUMBER() OVER(Partition By `Departure Station`)
 FROM railway_staging5
 WHERE `Price(GBP)` is NULL
 ;
 
 
SELECT
    `Purchase Type`,
    `Railcard`,
    `Ticket Class`,
    `Ticket Type`,
    `Departure Station`,
    `Arrival Destination`,
    COUNT(*) AS total_rows,
    COUNT(`Price(GBP)`) AS rows_with_price,
    MIN(`Price(GBP)`) AS price
FROM railway_staging5
GROUP BY
    `Purchase Type`,
    `Railcard`,
    `Ticket Class`,
    `Ticket Type`,
    `Departure Station`,
    `Arrival Destination`
HAVING
    COUNT(`Price(GBP)`) > 0
ORDER BY total_rows DESC;



START TRANSACTION;

UPDATE railway_staging5 AS r
JOIN (
    SELECT
        `Purchase Type`,
        `Railcard`,
        `Ticket Class`,
        `Ticket Type`,
        `Departure Station`,
        `Arrival Destination`,
        MIN(`Price(GBP)`) AS exact_price
    FROM railway_staging5
    WHERE `Price(GBP)` IS NOT NULL
    GROUP BY
        `Purchase Type`,
        `Railcard`,
        `Ticket Class`,
        `Ticket Type`,
        `Departure Station`,
        `Arrival Destination`
) AS lookup
ON  r.`Purchase Type` = lookup.`Purchase Type`
AND r.`Railcard` = lookup.`Railcard`
AND r.`Ticket Class` = lookup.`Ticket Class`
AND r.`Ticket Type` = lookup.`Ticket Type`
AND r.`Departure Station` = lookup.`Departure Station`
AND r.`Arrival Destination` = lookup.`Arrival Destination`
SET r.`Price(GBP)` = lookup.exact_price
WHERE r.`Price(GBP)` IS NULL;

COMMIT;
SELECT *
FROM railway_staging5
WHERE `Price(GBP)` is NULL;


SELECT *
FROM railway_staging5
WHERE 
-- `Price(GBP)` IS NULL and
`Departure Station` ='London St Pancras' and
`Arrival Destination` = 'Wolverhampton'
;




-- Data Cleaning Complete