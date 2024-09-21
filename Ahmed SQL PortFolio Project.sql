--1) 
-- Which individuals have the highest total sales year-to-date? 
--Please provide their first and last names along with the total sales amount, 
-- and sort the results by total sales in descending order

SELECT * FROM Person.Person
SELECT * FROM Sales.SalesPerson

SELECT pp.FirstName, pp.LastName, SUM(SalesYTD) AS Total_SalesYTD
FROM Person.Person pp
INNER JOIN Sales.SalesPerson sp
ON pp.BusinessEntityID = sp.BusinessEntityID
GROUP BY pp.FirstName, pp.LastName
ORDER BY Total_SalesYTD DESC;


--2)
--List male employees with their first and last names, 
--gender, job title, and a date that is 10 days after their birth date.

SELECT * FROM Person.Person
SELECT * FROM HumanResources.Employee

SELECT pp.FirstName, pp.LastName, HRE.Gender, HRE.JobTitle, DATEADD(dd, 10, HRE.BirthDate) AS Day_Addittion
FROM Person.Person pp
INNER JOIN HumanResources.Employee HRE
ON pp.BusinessEntityID = HRE.BusinessEntityID
WHERE HRE.Gender = 'M' 
GROUP BY pp.FirstName, pp.LastName, HRE.Gender, HRE.JobTitle, HRE.BirthDate
ORDER BY Day_Addittion;


--3)
--As an hr in an organization you have been tasked to present everybody that stays in washington,including thier AddressID


SELECT * FROM Person.vAdditionalContactInfo
SELECT * FROM Person.BusinessEntityAddress 

SELECT paci.FirstName, paci.LastName, pbea.AddressID, paci.StateProvince
FROM Person.vAdditionalContactInfo paci
LEFT JOIN Person.BusinessEntityAddress pbea
ON paci.BusinessEntityID = pbea.BusinessEntityID
WHERE paci.StateProvince = 'WA'
ORDER BY pbea.AddressID ASC;




--4)
--As a sales analyst You're given a task to retrieve the names and average unit price of sold products greater than naira 70, 
--along with the count of their total sales orders?
--The results should be sorted in descending order of total sales orders.

SELECT * FROM Sales.SalesOrderHeader soh;
SELECT * FROM Sales.SalesPerson sp;
SELECT * FROM Person.Person pp;
SELECT * FROM Sales.SalesOrderDetail sod;

SELECT pp.FirstName, pp.LastName, AVG(sod.UnitPrice) AS Average_UnitPrice, COUNT(soh.SalesOrderNumber) AS Total_Sales_Orders
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod 
ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Person.Person pp
ON pp.BusinessEntityID = soh.SalesPersonID  
GROUP BY pp.FirstName, pp.LastName
HAVING AVG(sod.UnitPrice) > 70 
ORDER BY Total_Sales_Orders DESC;



--5)
--As the mew production manager you're given a task to retreieve the details (name, product number, color, and product photo ID) 
--of products associated with the productphoto ID '1'
--in the Production database, and how might this information help us analyze product visibility and marketing strategie

SELECT * FROM Production.ProductProductPhoto pppSELECT * FROM Production.Product pp

SELECT pp.Name, pp.ProductNumber, pp.color, ppp.ProductPhotoID
FROM Production.Product pp
INNER JOIN Production.ProductProductPhoto ppp
ON pp.ProductID = ppp.ProductID
WHERE ppp.ProductPhotoID = '1'
GROUP BY pp.Name, pp.ProductNumber, pp.color, ppp.ProductPhotoID;




--Using Sub-Query 

--1)
--What are the names, list prices, and colors of products 
--with the highest price where color is NULL.
SELECT * FROM Person.Person pp 
SELECT * FROM Production.Product pp

SELECT Name, ListPrice, Color 
FROM Production.Product 
WHERE ListPrice = (
    SELECT MAX(ListPrice) 
    FROM Production.Product 
    WHERE Color IS NULL
);



--2)
--Which employees have a phone number listed as 'WORK' 
SELECT FirstName, LastName, PhoneNumber, PhoneNumberType
FROM HumanResources.vEmployee
WHERE PhoneNumber IN (
    SELECT PhoneNumber
    FROM HumanResources.vEmployee
    WHERE PhoneNumberType = 'WORK'
)
ORDER BY PhoneNumber ASC;



--Using Join And Sub_Query Together
--3)What are the names and product models of products along with their received quantities from the 
--Purchasing.PurchaseOrderDetail table that have the highest received quantity for each product? 

SELECT * FROM Purchasing.PurchaseOrderDetail pod
SELECT * FROM Production.vProductAndDescription pad

SELECT pad.Name, pad.ProductModel, pod.ReceivedQty
FROM Purchasing.PurchaseOrderDetail pod
JOIN Production.vProductAndDescription pad 
	ON pod.ProductID = pad.ProductID
WHERE pod.ReceivedQty = 
		(
        SELECT MAX(ReceivedQty)
        FROM Purchasing.PurchaseOrderDetail
        WHERE ProductID = pod.ProductID
    );



--4)
--As an Hr you're given a task to retrieve the top three names and addition of 10 days in each names BirthDate

SELECT* FROM Person.Person pp 
SELECT* FROM HumanResources.Employee hre


SELECT TOP 3 pp.FirstName, pp.LastName, AdjustedBirthDate
FROM Person.Person pp
JOIN (
    SELECT hre.BusinessEntityID, DATEADD(DAY, 10, hre.BirthDate) AS AdjustedBirthDate
    FROM HumanResources.Employee hre
	) AS adjusted 
ON pp.BusinessEntityID = adjusted.BusinessEntityID
ORDER BY pp.FirstName;


--5)
--List the Product  placed by customers,including their ProductNumber for products in the 'Black' Color category alone .
SELECT * FROM Production.Product pp

SELECT ProductID, Name, ProductNumber, Color
FROM	Production.Product pp
WHERE pp.Color = 'Black' AND pp.ProductNumber IN (
    SELECT pp.ProductNumber
    FROM Production.Product pp
);




--CTE Function


--1)
----List the Product  placed by customers,including their ProductNumber for products in the 'Black' Color category alone .
SELECT * FROM Production.Product pp

WITH ProductCTE AS (
    SELECT ProductNumber
    FROM Production.Product
)

SELECT ProductID, Name, ProductNumber, Color
FROM Production.Product pp
WHERE pp.Color = 'Black' 
  AND pp.ProductNumber IN (SELECT ProductNumber FROM ProductCTE);


--2)
--As a sales  manager you're required to retrieve the Product_name,Product_Model and get the received quantity  
SELECT * FROM Purchasing.PurchaseOrderDetail pod
SELECT * FROM Production.vProductAndDescription pad

WITH MaxReceivedQty_CTE AS 
    (SELECT ProductID, MAX(ReceivedQty) AS MaxReceivedQty
    FROM Purchasing.PurchaseOrderDetail
    GROUP BY ProductID)

SELECT pad.Name, pad.ProductModel, pod.ReceivedQty
FROM Purchasing.PurchaseOrderDetail pod
JOIN Production.vProductAndDescription pad 
    ON pod.ProductID = pad.ProductID
JOIN MaxReceivedQty_CTE mq
    ON pod.ProductID = mq.ProductID AND pod.ReceivedQty = mq.MaxReceivedQty;


--3)
--Which individuals have the highest total sales year-to-date? 
--Please provide their first and last names along with the total sales amount, 
-- and sort the results by total sales in descending order

SELECT * FROM Person.Person
SELECT * FROM Sales.SalesPerson

WITH Sales_CTE AS 
    (SELECT pp.FirstName, pp.LastName, SUM(sp.SalesYTD) AS Total_SalesYTD
    FROM Person.Person pp
    INNER JOIN Sales.SalesPerson sp
        ON pp.BusinessEntityID = sp.BusinessEntityID
    GROUP BY pp.FirstName, pp.LastName)
SELECT FirstName, LastName, Total_SalesYTD
FROM Sales_CTE
ORDER BY Total_SalesYTD DESC;

--4)
--you're required to extract the staffs located in USA alone 
SELECT * FROM Person.vAdditionalContactInfo


WITH CountryRegionCTE AS (
    SELECT *
    FROM Person.vAdditionalContactInfo
    WHERE CountryRegion = 'USA'
)
SELECT *
FROM CountryRegionCTE;

--5)
--As production manager in an organization your're given a task to get the  of the List price above 1000
SELECT * FROM Production.ProductWITH ListPriceCTE AS (
    SELECT *
    FROM Production.Product
    WHERE ListPrice > 1000 -- Replace this with a specific value if needed
)
SELECT *
FROM ListPriceCTE;



		





