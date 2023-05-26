SELECT *
FROM [E Commerce].[dbo].[SalesTransaction]

-----------------------------------------------------------------------------------------------------------


--Identify duplicate value and remove the duplicate value from the table

SELECT TransactionNo, Date, ProductName, Price, Quantity, Country, COUNT(*) AS DuplicateCount
FROM [E Commerce].[dbo].[SalesTransaction]
WHERE ProductName = 'Metal Sign Cupcake Single Hook'
GROUP BY TransactionNo, Date, ProductName, Price, Quantity, Country
HAVING COUNT(*) > 1


WITH CTE AS (
	SELECT TransactionNo, Date, CustomerNo, ProductName, Price, Quantity, Country, 
	ROW_NUMBER() OVER (PARTITION BY TransactionNo, Date, CustomerNo, ProductName, Price, Quantity, Country ORDER BY (SELECT 0)) AS RowNum
	FROM [E Commerce].[dbo].[SalesTransaction]
	WHERE Date is not null
	)
--SELECT TransactionNo, Date, CustomerNo, ProductName, Price, Quantity, Country
--FROM CTE
--WHERE RowNum > 1
DELETE FROM CTE
WHERE RowNum > 1

SELECT *
FROM [E Commerce].[dbo].[SalesTransaction]
WHERE TransactionNo = '551747' AND ProductName = 'Metal Sign Cupcake Single Hook'


-----------------------------------------------------------------------------------------------------------


--Remove cancel transaction, the letter 'C' in TransactionNo means the transaction is cancel

SELECT *
FROM [E Commerce].[dbo].[SalesTransaction]
WHERE TransactionNo LIKE '%C%'

DELETE FROM [E Commerce].[dbo].[SalesTransaction]
WHERE TransactionNo LIKE '%C%'

--8519 rows is removed



-----------------------------------------------------------------------------------------------------------


--Identify NULL value

SELECT *
FROM [E Commerce].[dbo].[SalesTransaction]
WHERE TransactionNo IS NULL 
	OR Date IS NULL
	OR ProductNo IS NULL
	OR ProductName IS NULL
	OR Price IS NULL
	OR Quantity IS NULL
	OR CustomerNo IS NULL
	OR Country IS NULL

-- No NULL value :)


-----------------------------------------------------------------------------------------------------------


--ANALYZE PHASE


--Sales trend over months
SELECT YEAR(Date) AS SaleYear, MONTH(Date) AS SaleMonth, SUM(Price*Quantity) AS TotalSales
FROM [E Commerce].[dbo].[SalesTransaction]
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY TotalSales DESC
--The highest sales trend during September until November


--TotalSale for each country
SELECT Country, SUM(Price*Quantity) As TotalSales, 
(SUM(Price*Quantity)/(SELECT SUM(Price*Quantity) FROM [E Commerce].[dbo].[SalesTransaction])) * 100 AS Percentage
FROM [E Commerce].[dbo].[SalesTransaction]
GROUP BY Country 
ORDER BY TotalSales DESC
--Majority of the sale came from United Kingdom where it accumulate 83.38% of total sales


--Average Sale by months 
SELECT YEAR(Date) AS SaleYear, MONTH(Date) AS SaleMonth, AVG(Price*Quantity) AS AvgSales
FROM [E Commerce].[dbo].[SalesTransaction]
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY AvgSales DESC

--Average Quantity by months
SELECT YEAR(Date) AS SaleYear, MONTH(Date) AS SaleMonth, AVG(Quantity) AS AvgQuantity
FROM [E Commerce].[dbo].[SalesTransaction]
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY AvgQuantity DESC


--Find total quantity purchased over months
SELECT YEAR(Date) AS SaleYear, MONTH(Date) AS SaleMonth, SUM(Quantity) AS TotalQuantity
FROM [E Commerce].[dbo].[SalesTransaction]
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY TotalQuantity DESC
--The highest quantity purchased is same with sales trend, the peak from September until November


--Find the most purchased product 
SELECT TOP 5 ProductName, SUM(Quantity) AS TotalQuantity
FROM [E Commerce].[dbo].[SalesTransaction]
GROUP BY ProductName
ORDER BY TotalQuantity DESC


--Find the most purchased product in United Kingdom 
SELECT TOP 5 ProductName, SUM(Quantity) AS TotalQuantity
FROM [E Commerce].[dbo].[SalesTransaction]
WHERE Country = 'United Kingdom'
GROUP BY ProductName
ORDER BY TotalQuantity DESC
--The top 5 most product sell in UK is the same with another countries. The highest product sold is Paper Craft Little Birdie which 100% sold in UK


--Find TOP 10 total sale product
SELECT TOP 10 ProductName, Quantity, SUM(Price*Quantity) AS TotalSale
FROM [E Commerce].[dbo].[SalesTransaction]
GROUP BY ProductName, Quantity
ORDER BY TotalSale DESC


--Find what type of products customer purchased from September until November since it the most highest volume of purchased items
SELECT TOP 50 ProductName, SUM(Quantity) AS TotalPurchases 
FROM [E Commerce].[dbo].[SalesTransaction]
WHERE Date >= '2019-09-01' AND Date <= '2019-11-30'
GROUP BY ProductName
ORDER BY TotalPurchases DESC
--It can be concluded that the top purchased items from September until November is kitchenware, home decor, toys and craft for various celebration such as Hallowen and Christmas


-----------------------------------------------------------------------------------------------------------

--Add new column for TotalSale column in the table for data visualization 
ALTER TABLE [E Commerce].[dbo].[SalesTransaction]
ADD TotalSale DECIMAL(10,2)

UPDATE [E Commerce].[dbo].[SalesTransaction]
SET TotalSale = Quantity * Price