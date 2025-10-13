-- Reports for total revenue
USE Hotel_Booking;
GO

-- Revenue
CREATE OR ALTER VIEW Revenue AS
SELECT a.*,
RoomRevenue + ISNULL(OrderRevenue,0) AS TotalRevenue,
R.[Request Type],
R.Adults,
R.Children
FROM (
	SELECT BookingID,
	Room,
	StartDate,
	EndDate,
	RequestID,
	RoomID,
	R.Price,
	Capacity,
	[Type],
	DATEDIFF(dd,StartDate,EndDate)* R.Price AS RoomRevenue,
	SUM(NumOrders*M.Price) AS OrderRevenue
	FROM [Bookings] B
	LEFT JOIN [Rooms] R
		ON LEFT(B.Room,1)=R.Prefix
	LEFT JOIN [FoodOrders] FO
		ON B.Room=FO.BillRoom 
		AND FO.[Date] BETWEEN B.StartDate AND B.EndDate
	LEFT JOIN [Menu] M
		ON FO.MenuID = M.MenuID
	GROUP BY BookingID,Room,StartDate,EndDate,RequestID,RoomID,R.Price,Capacity,[Type]
	) a
	LEFT JOIN Requests R
		ON a.RequestID = R.RequestID;
GO

--Time-based Trends: Revenue by month
SELECT YEAR(StartDate) AS Year, 
MONTH(StartDate) AS Month, 
SUM(TotalRevenue) AS MonthlyRevenue,
COUNT(BookingID) AS TotalBookings
FROM Revenue
GROUP BY YEAR(StartDate), MONTH(StartDate);


--Product analysis: revenue by room type
SELECT [Type],
SUM(RoomRevenue) AS TotalRoomRevenue,
SUM(OrderRevenue) AS TotalOrderRevenue,
SUM(TotalRevenue) AS TotalRevenue,
AVG(RoomRevenue) AS AverageRoomRevenue,
AVG(OrderRevenue) AS AverageOrderRevenue,
AVG(TotalRevenue) AS AverageTotalRevenue
FROM Revenue
GROUP BY [Type];


--Customer behaviour: revenue and freq of request type
SELECT [Request Type],
SUM(RoomRevenue) AS TotalRoomRevenue,
SUM(OrderRevenue) AS TotalOrderRevenue,
SUM(TotalRevenue) AS TotalRevenue,
COUNT(BookingID) AS Frequency,
AVG(Adults + Children) AS AvgGuests
FROM Revenue
GROUP BY [Request Type]

--Time-based Trends across customer request type
SELECT 
    YEAR(StartDate) AS Year,
    MONTH(StartDate) AS Month,
    [Request Type],
    SUM(TotalRevenue) AS Revenue,
	COUNT(BookingID) AS Frequency,
	AVG(Adults + Children) AS AvgGuests
FROM Revenue
GROUP BY YEAR(StartDate), MONTH(StartDate), [Request Type]
ORDER BY Year, Month, [Request Type];


--Room Capacities & Usage: whether they¡¯re underused or overused.
SELECT Type,
    Capacity,
	AVG(Adults) AS Adults,
	AVG(Children) AS Children,
	Price,
    COUNT(BookingID) AS Frequency,
    SUM(DATEDIFF(DAY, StartDate, EndDate)) AS TotalDaysBooked
FROM Revenue
GROUP BY Type, Capacity, Price
ORDER BY Capacity;

--Room Utilization Rate: Average by roomtype
DECLARE @PeriodStart DATE = (SELECT MIN(StartDate) FROM Bookings);
DECLARE @PeriodEnd DATE = (SELECT MAX(EndDate) FROM Bookings);
WITH CTE AS(
SELECT Room, [Type],
    SUM(DATEDIFF(DAY, StartDate, EndDate)) AS DaysBooked,
	DATEDIFF(DAY, @PeriodStart, @PeriodEnd) AS TotalDaysAvailable,
    CAST(SUM(DATEDIFF(DAY, StartDate, EndDate)) * 100.0 / DATEDIFF(DAY, @PeriodStart, @PeriodEnd) AS DECIMAL(5,2)) AS UtilizationRate
FROM Revenue
GROUP BY Room,[Type]
)
SELECT Type, 
AVG(UtilizationRate) AS AvgUtilizationRate
FROM CTE
GROUP BY Type
ORDER BY 2 DESC;