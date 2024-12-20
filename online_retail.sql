-- select the database or create the database you have to choose;
use assignment;

-- create the table or import the data from the cvs file
-- viewing the data 
Select * from online_retail;
/*
The Online Retail Dataset typically contains information about sales transactions, including details such as invoice numbers, product IDs,
 quantities, unit prices, customer information, and more. The questions below are designed to test your ability to use SQL queries to analyze 
 and gain insights from such a dataset. They include advanced SQL concepts such as joins, aggregations, window functions, and subqueries.

Explaining Online Retail Dataset Structure:
InvoiceNo: Invoice number
StockCode: Unique identifier for the product
Description: Product description
Quantity: Number of units sold
InvoiceDate: Date and time of the invoice
UnitPrice: Price per unit of the product
CustomerID: Unique customer identifier
Country: Country of the customer 
*/
-- Write an SQL query to calculate the total revenue generated by each product in the dataset.
SELECT StockCode, Description, Round(SUM(Quantity * UnitPrice),2) AS TotalRevenue
FROM online_retail
GROUP BY StockCode, Description
ORDER BY TotalRevenue DESC;

-- Write an SQL query to find the top 10 products based on the total quantity sold.
SELECT StockCode, Description, SUM(Quantity) AS TotalQuantitySold
FROM online_retail
GROUP BY StockCode, Description
ORDER BY TotalQuantitySold DESC
LIMIT 10;

-- Write an SQL query to calculate the average order value for each country.
SELECT Country, Round(AVG(TotalOrderValue),1) AS AverageOrderValue
FROM (
    SELECT InvoiceNo, Country, Round(SUM(Quantity * UnitPrice),1) AS TotalOrderValue
    FROM online_retail
    GROUP BY InvoiceNo, Country
) AS OrderValues
GROUP BY Country
ORDER BY AverageOrderValue DESC;

-- Write an SQL query to find the frequency of purchases per customer.
SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS NumberOfPurchases
FROM online_retail
GROUP BY CustomerID
ORDER BY NumberOfPurchases DESC;

-- Write an SQL query to calculate the customer lifetime value (CLV), which is the total amount spent by each customer.
SELECT CustomerID, Round(SUM(Quantity * UnitPrice),1)AS LifetimeValue
FROM online_retail
GROUP BY CustomerID
ORDER BY LifetimeValue DESC;

-- Write an SQL query to find the total number of products sold by country.
SELECT Country, SUM(Quantity) AS TotalProductsSold
FROM online_retail
GROUP BY Country
ORDER BY TotalProductsSold DESC;

-- Write an SQL query to analyze the monthly sales trends (revenue) over time.
SELECT YEAR(InvoiceDate) AS Year, MONTH(InvoiceDate) AS Month, 
       Round(SUM(Quantity * UnitPrice),2) AS MonthlySales
FROM online_retail
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY Year, Month;

-- Write an SQL query to calculate the total revenue for each invoice, including discounts (if available in the dataset).
SELECT InvoiceNo, Round(SUM(Quantity * UnitPrice),2) AS TotalRevenue
FROM online_retail
GROUP BY InvoiceNo
ORDER BY TotalRevenue DESC;

-- Write an SQL query to rank products based on the revenue in each country.
SELECT Country, StockCode, Description, 
       Round(SUM(Quantity * UnitPrice),2) AS TotalRevenue,
       RANK() OVER (PARTITION BY Country ORDER BY Round(SUM(Quantity * UnitPrice),2) DESC) AS ProductRank
FROM online_retail
GROUP BY Country, StockCode, Description
ORDER BY Country, ProductRank;

-- Write an SQL query to find the top 5 customers who spent the most in total.
SELECT CustomerID, Round(SUM(Quantity * UnitPrice),2) AS TotalSpend
FROM online_retail
GROUP BY CustomerID
ORDER BY TotalSpend DESC
LIMIT 5;

-- Write an SQL query to identify products that have negative quantities in the dataset (e.g., returns or cancellations).
SELECT StockCode, Description, SUM(Quantity) AS TotalQuantity
FROM online_retail
GROUP BY StockCode, Description
HAVING SUM(Quantity) < 0;

-- Write an SQL query to find customers who have not made any purchases in the last 6 months with there product quantity.
SELECT CustomerID, sum(Quantity)
FROM online_retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
HAVING MAX(InvoiceDate) < CURDATE() - INTERVAL 6 MONTH;

-- Write an SQL query to find pairs of products that never appeared in the same invoice.
SELECT p1.StockCode AS Product1, p2.StockCode AS Product2
FROM online_retail p1
JOIN online_retail p2 ON p1.InvoiceNo = p2.InvoiceNo AND p1.StockCode < p2.StockCode
GROUP BY p1.StockCode, p2.StockCode
HAVING COUNT(*) = 0;

-- Write an SQL query to calculate a 3-month moving average of total sales for each product.
WITH MonthlySales AS (
    SELECT 
        YEAR(InvoiceDate) AS Year,
        MONTH(InvoiceDate) AS Month,
        StockCode,
        SUM(Quantity * UnitPrice) AS TotalSales
    FROM online_retail
    GROUP BY Year, Month, StockCode
)
SELECT Year, Month, StockCode, TotalSales,
       AVG(TotalSales) OVER (PARTITION BY StockCode ORDER BY Year, Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg
FROM MonthlySales
ORDER BY StockCode, Year, Month;

-- Write an SQL query to identify seasonal sales patterns by calculating the average sales per season for each product.

SELECT StockCode, Description,
       CASE 
           WHEN MONTH(InvoiceDate) IN (12, 1, 2) THEN 'Winter'
           WHEN MONTH(InvoiceDate) IN (3, 4, 5) THEN 'Spring'
           WHEN MONTH(InvoiceDate) IN (6, 7, 8) THEN 'Summer'
           WHEN MONTH(InvoiceDate) IN (9, 10, 11) THEN 'Fall'
       END AS Season,
      Round(AVG(Quantity * UnitPrice),2) AS AverageSales
FROM online_retail
GROUP BY StockCode, Description, Season
ORDER BY Season, AverageSales DESC;
