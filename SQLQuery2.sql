create database Practice;
use Practice;

--creating tables
-- Create Categories Table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100)
);

-- Create Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    Price DECIMAL(10, 2),
    StockQuantity INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20)
);

-- Create Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create OrderDetails Table
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert into Categories
INSERT INTO Categories VALUES 
(1, 'Laptops'),
(2, 'Smartphones'),
(3, 'Accessories');

-- Insert into Products
INSERT INTO Products VALUES
(101, 'Dell XPS 13', 1, 95000.00, 15),
(102, 'iPhone 14', 2, 80000.00, 8),
(103, 'USB-C Cable', 3, 500.00, 100),
(104, 'Samsung Galaxy S22', 2, 70000.00, 5);

-- Insert into Customers
INSERT INTO Customers VALUES
(1, 'Alice Johnson', 'alice@example.com', '9876543210'),
(2, 'Bob Smith', 'bob@example.com', '9123456780');

-- Insert into Orders
INSERT INTO Orders VALUES
(1001, 1, '2025-07-01', 160000.00),
(1002, 2, '2025-07-15', 70500.00);

-- Insert into OrderDetails
INSERT INTO OrderDetails VALUES
(1, 1001, 101, 1, 95000.00),
(2, 1001, 102, 1, 80000.00),
(3, 1002, 104, 1, 70000.00),
(4, 1002, 103, 1, 500.00);

--As a Sales Manager, I want to view total sales per product category to analyze performance.
SELECT 
    c.CategoryName,
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM 
    Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY 
    c.CategoryName;

--As a Warehouse Supervisor, I need to check low-stock items to initiate restocking.
SELECT 
    ProductID, ProductName, StockQuantity
FROM 
    Products
WHERE 
    StockQuantity < 10
order by StockQuantity asc;

--As a Customer Support Agent, I need to fetch order details with customer information for issue resolution.
SELECT 
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    c.Email,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) AS LineTotal
FROM 
    Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE 
    o.OrderID = 1001; -- Example order ID

--As a Database Administrator, I need to ensure atomicity when updating stock levels during bulk orders.
CREATE PROCEDURE ProcessOrder
    (@inputOrderID INT)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update stock
        UPDATE Products
        SET StockQuantity = StockQuantity - od.Quantity
        FROM Products AS p
        JOIN OrderDetails od ON p.ProductID = od.ProductID
        WHERE od.OrderID = @inputOrderID;

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
    END CATCH
END;

execute ProcessOrder 1001;

select * from OrderDetails;
SELECT 
    ProductID,
    ProductName,
    StockQuantity
FROM 
    Products;

    --discount
CREATE FUNCTION GetDiscountedPrice
(
    @originalPrice DECIMAL(10, 2),
    @discountPercent INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN @originalPrice * (1- @discountPercent / 100.0);
END;
SELECT dbo.GetDiscountedPrice(1000, 10) AS DiscountedPrice;
-- Output: 850.00


--generating monthly sales report
CREATE VIEW MonthlySalesReport 
AS
SELECT 
    FORMAT(OrderDate, 'yyyy-MM') AS [Month],
    SUM(TotalAmount) AS TotalSales
FROM 
    Orders
GROUP BY 
    FORMAT(OrderDate, 'yyyy-MM');
go

select * from MonthlySalesReport;

--else sales generate
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    p.Price,
    p.StockQuantity
FROM 
    Products p
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY 
    p.StockQuantity ASC;


----customer order History
SELECT c.CustomerName,o.OrderDate,p.ProductName,od.Quantity
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID;

CREATE Function GetDiscountedPrice1(@price decimal(10,2),@discount decimal(5,2))
returns decimal(10,2)
AS
BEGIN
return @price * (1-@discount/100);
END

Select dbo.GetDiscountedPrice1(1000,10) AS DiscountedPrice;

CREATE function GetProductByCategory(@CategoryID int)
returns table
AS
return
(Select ProductName,Price,ProductID,StockQuantity
From Products
Where CategoryID = @CategoryID);

Select * from dbo.GetProductByCategory(1);


Create Table Student(
StudentID int Primary Key,
FullName varchar(100) not null,
Email varchar(100) Unique not null,
age int check (age >= 18)
);

Create Table Instructor(
InstructorID int Primary Key,
FullName varchar(100),
Email varchar(100) Unique
);

Create Table Course(
courseID int Primary Key,
CourseName varchar(100),
InstructorID int,
Foreign key (InstructorID) References Instructor (InstructorId)
);

Create Table Enrollment(
EnrollmentID int Primary Key,
StudentID int,
CourseID int,
EnrollementDate Date Default GETDATE(),
Foreign key (StudentID) References Student(StudentID),
Foreign key (CourseID) References Course(CourseID)
);

--Inserting in to above tables
Insert into Instructor Values(1, 'Dr. Smith', 'Smith@gmail.com'); 
Insert into Instructor Values (2, 'Prof ManiZ', 'Mani@gmail.com');

--inserting course tables vaulse
insert into course values(101, 'Data Science', 1);
insert into Course values(102, 'web Developmnet', 2);

--inserting into Student
Insert into student values (1, 'Rohit', 'Rohit@gUCla.Uk', 17);-- will not work as age is above 18
Insert into student values (1, 'Rohit', 'Rohit@gUCla.Uk', 19);

Insert into student values (2, 'Rohit', 'Rohit2@gUCla.Uk', 19);

Insert into student values (3,'Rohit', 'Rohit3@gUCla.Uk', 19);

--inserting values with Enrollement

insert into Enrollment values( 1001, 1, 101,GETDATE());
insert into Enrollment values( 1002, 2, 102,GETDATE());
insert into Enrollment values( 1001, 1, 101,GETDATE());
Select * from Enrollment;


--for above to week we have to create login and users
Create login auditor with Password = 'StrongPassword123';
Create user auditor for login auditor;

--Grant and Revoke for auditor
Grant select on Student to auditor;
Grant select on Student to auditor;
Grant select on Enrollment to auditor;



Revoke Select on Student From Auditor;--For revoking access after some time

--Implementing a transaction with commit and roll back

begin transaction;
insert into student values(5,'Alex', 'Alex@HWD.edu', 21);

insert into Enrollment values(1005,5,101,Getdate());
commit;

--ROLLBACK TRANSACTION
Begin Transaction;
Insert into Student values (6,'Angle','Angle@cla.um',18);
RollBack;

-- 1. Which Students are enrolled in which courses?
SELECT s.Name, c.CourseName
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
JOIN Course c ON e.CourseID = c.CourseID;

-- 2. Who is teaching each course?
SELECT c.CourseName, i.FullName
FROM Course c
JOIN Instructor i ON c.InstructorID = i.InstructorID;
