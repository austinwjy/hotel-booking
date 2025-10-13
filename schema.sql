CREATE DATABASE Hotel_Booking;

USE Hotel_Booking;

--Create table schemas
CREATE TABLE [Requests](
RequestID INT PRIMARY KEY,
[Client Name] VARCHAR(50) NOT NULL,
[Room Type] VARCHAR(50) NOT NULL,
[Request Type] VARCHAR(50) NOT NULL,
StartDate DATETIME NOT NULL,
EndDate DATETIME NOT NULL,
Adults INT NOT NULL,
Children INT NOT NULL
);


CREATE TABLE Bookings(
BookingID INT PRIMARY KEY,
Room VARCHAR(50) NOT NULL,
StartDate DATETIME NOT NULL,
EndDate DATETIME NOT NULL,
RequestID INT NOT NULL FOREIGN KEY REFERENCES Requests(RequestID),
);


CREATE TABLE Rooms(
RoomID INT PRIMARY KEY,
Price TINYINT NOT NULL,
Capacity TINYINT NOT NULL,
[Type] VARCHAR(50) NOT NULL,
Prefix VARCHAR(20) NOT NULL,
);


CREATE TABLE Menu(
MenuID INT PRIMARY KEY,
[Name] VARCHAR(50) NOT NULL,
Price DECIMAL(5,2) NOT NULL,
Category VARCHAR(50) NOT NULL
);


CREATE TABLE FoodOrders(
OrderID INT IDENTITY(1,1) PRIMARY KEY,
DestRoom VARCHAR(50) NOT NULL,
BillRoom VARCHAR(50) NOT NULL,
[Date] DATE NOT NULL,
[Time] VARCHAR(50) NOT NULL,
NumOrders INT NOT NULL,
MenuID INT NOT NULL FOREIGN KEY REFERENCES Menu(MenuID)
);


-- Mapping csv file into database by Import Wizard: tasks -> import data
