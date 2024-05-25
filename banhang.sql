create database DA1;
use DA1;
select * from banhang; -- xóa sale_name, cus_name
select * from customer;
select * from branch;
select * from staff;
select * from ty_gia;




-- Clean data
CREATE PROCEDURE RemoveQuotesFromColumn
    @TableName NVARCHAR(128),
    @ColumnName NVARCHAR(128)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX)

    SET @SQL = '
        UPDATE ' + QUOTENAME(@TableName) + '
        SET ' + QUOTENAME(@ColumnName) + ' = 
            CASE 
                WHEN LEFT(' + QUOTENAME(@ColumnName) + ', 1) = ''"'' AND RIGHT(' + QUOTENAME(@ColumnName) + ', 1)
				= ''"'' THEN SUBSTRING(' + QUOTENAME(@ColumnName) + ', 2, LEN(' + QUOTENAME(@ColumnName) +')-2)
                WHEN LEFT(' + QUOTENAME(@ColumnName) + ', 1) = ''"'' THEN SUBSTRING(' + QUOTENAME(@ColumnName) + ', 2, 
				LEN(' + QUOTENAME(@ColumnName) + '))
                WHEN RIGHT(' + QUOTENAME(@ColumnName) + ', 1) = ''"'' THEN LEFT(' + QUOTENAME(@ColumnName) + ', 
				LEN(' + QUOTENAME(@ColumnName) + ') - 1)
                ELSE ' + QUOTENAME(@ColumnName) + '
            END'
 EXEC(@SQL)	
END



EXEC RemoveQuotesFromColumn @TableName = 'branch', @ColumnName = 'STOREDID'
EXEC RemoveQuotesFromColumn @TableName = 'branch', @ColumnName = 'MANAGER'

EXEC RemoveQuotesFromColumn @TableName = 'staff', @ColumnName = 'SALE_NAME'
EXEC RemoveQuotesFromColumn @TableName = 'staff', @ColumnName = 'HE_SO_LUONG'

EXEC RemoveQuotesFromColumn @TableName = 'ty_gia', @ColumnName = 'BUSINESS_DATE'
EXEC RemoveQuotesFromColumn @TableName = 'ty_gia', @ColumnName = 'EXCHANGE_RATE'

-- Check data type
-- banhang
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'banhang'

--branch
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'branch'

--customer 
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer'

-- staff
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'staff'
-- chang type
ALTER TABLE staff
ALTER COLUMN HE_SO_LUONG INT

-- tygia
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ty_gia'

ALTER TABLE ty_gia
ALTER COLUMN BUSINESS_DATE date;

ALTER TABLE ty_gia
ALTER COLUMN EXCHANGE_RATE int;

-- Truy van 

--Tổng doanh thu từ các giao dịch bán hàng theo tháng/năm:
SELECT 
    YEAR(TRANS_DATE) AS Nam,
    MONTH(TRANS_DATE) AS Thang,
    FORMAT(SUM(UNIT_PRICE - SALE_OFF + CHAMTRA), 'N0') AS TongDoanhThu
FROM 
    banhang
GROUP BY 
    YEAR(TRANS_DATE), MONTH(TRANS_DATE)
ORDER BY 
    YEAR(TRANS_DATE), MONTH(TRANS_DATE)

-- Doanh thu từng cửa hàng theo thời gian:
SELECT 
    STOREDID,
    YEAR(TRANS_DATE) AS Nam,
    MONTH(TRANS_DATE) AS Thang,
    FORMAT(SUM(UNIT_PRICE - SALE_OFF + CHAMTRA), 'N0') AS TongDoanhThu
FROM 
    banhang
GROUP BY 
    STOREDID, YEAR(TRANS_DATE), MONTH(TRANS_DATE)
ORDER BY 
    STOREDID, YEAR(TRANS_DATE), MONTH(TRANS_DATE);

--Doanh số bán hàng của mỗi nhân viên:
SELECT 
    SALE_ID,
    SALE_NAME,
    SUM(FCY_AMT) AS DoanhSo
FROM 
    banhang
GROUP BY 
    SALE_ID, SALE_NAME
ORDER BY 
    SUM(FCY_AMT) DESC;

SELECT 
    TRANS_TYPE,
    SUM(FCY_AMT) AS TongSoLuong
FROM 
    banhang
GROUP BY 
    TRANS_TYPE



-- Xu hướng mua hàng của từng loại khách hàng 
SELECT 
	CUS_TYPE, 
	PRODUCT_NAME,
	COUNT(*) AS total_purchases
FROM banhang b join customer c on b.CUS_ID = c.CUS_ID
GROUP BY CUS_TYPE, PRODUCT_NAME
ORDER BY CUS_TYPE, total_purchases DESC;


-- Doanh thu từ từng loại khách hàng
SELECT
	c.CUS_TYPE, 
	YEAR(bh.TRANS_DATE) as year,
	SUM(bh.FCY_AMT) AS TotalRevenue
FROM banhang bh
JOIN customer c ON bh.CUS_ID = c.CUS_ID
GROUP BY c.CUS_TYPE, YEAR(bh.TRANS_DATE)
ORDER BY CUS_TYPE ;

select distinct year(trans_date)  from banhang

--  Tỷ lệ khách hàng nam (Mr) và nữ (Ms) mua hàng 
SELECT 
	c.SEX, 
	year(bh.TRANS_DATE) as YEAR,
	COUNT(DISTINCT c.CUS_ID) AS CustomerCount
FROM banhang bh
JOIN customer c ON bh.CUS_ID = c.CUS_ID
GROUP BY c.SEX, year(bh.TRANS_DATE)
ORDER BY YEAR


SELECT bh.TRANS_TYPE, c.CUS_NAME, c.CUS_ID, AVG(FCY_AMT) AS AverageTransactionValue
FROM banhang bh
JOIN customer c ON bh.CUS_ID = c.CUS_ID
GROUP BY bh.TRANS_TYPE, c.CUS_NAME, c.CUS_ID
ORDER BY bh.TRANS_TYPE, AverageTransactionValue DESC;


--  Nhân viên bán hàng có tổng doanh số cao nhất theo từng tháng là ai?
WITH HIHI AS
(
SELECT
	YEAR(BH.TRANS_DATE) AS YEAR, MONTH(BH.TRANS_DATE) AS MONTH,
	S.SALE_NAME, SUM(BH.FCY_AMT) AS TOTALSALES,
	RANK() OVER(PARTITION BY YEAR(BH.TRANS_DATE), MONTH(BH.TRANS_DATE) ORDER BY SUM(BH.FCY_AMT) DESC) AS RANK
FROM BANHANG BH
JOIN STAFF S ON BH.SALE_ID = S.SALE_ID
GROUP BY YEAR(BH.TRANS_DATE), MONTH(BH.TRANS_DATE), S.SALE_NAME, S.SALE_ID
)
SELECT YEAR, MONTH, SALE_NAME, TOTALSALES FROM HIHI
WHERE RANK = 1
ORDER BY YEAR, MONTH 


-- Tổng số giao dịch của mỗi nhân viên bán hàng theo từng tháng?
SELECT 
	YEAR(bh.TRANS_DATE) AS Year,
	MONTH(bh.TRANS_DATE) AS Month, 
	s.SALE_NAME, s.SALE_ID, COUNT(bh.SALE_ID) AS TotalTransactions
FROM banhang bh
JOIN staff s ON bh.SALE_ID = s.SALE_ID
GROUP BY YEAR(bh.TRANS_DATE), MONTH(bh.TRANS_DATE), s.SALE_NAME, s.SALE_ID
ORDER BY Year, Month, TotalTransactions DESC;

-- Nhân viên bán hàng có doanh thu trung bình mỗi giao dịch cao nhất theo từng năm?
SELECT YEAR(bh.TRANS_DATE) AS Year, s.SALE_NAME, s.SALE_ID, AVG(bh.FCY_AMT) AS AverageTransactionValue
FROM banhang bh
JOIN staff s ON bh.SALE_ID = s.SALE_ID
GROUP BY YEAR(bh.TRANS_DATE), s.SALE_NAME, s.SALE_ID
ORDER BY Year, AverageTransactionValue DESC;

-- Tổng hoa hồng (COMMISSION) nhận được của mỗi nhân viên bán hàng theo từng năm?
SELECT YEAR(bh.TRANS_DATE) AS Year, s.SALE_NAME, s.SALE_ID, SUM(bh.COMMISSION) AS TotalCommission
FROM banhang bh
JOIN staff s ON bh.SALE_ID = s.SALE_ID
GROUP BY YEAR(bh.TRANS_DATE), s.SALE_NAME, s.SALE_ID
ORDER BY Year, TotalCommission DESC;

-- Hiệu suất của nhân viên bán hàng theo từng chi nhánh (doanh thu của nhân viên tại mỗi chi nhánh) theo từng năm?
SELECT YEAR(bh.TRANS_DATE) AS Year, b.STOREDID, b.ADDRESS, s.SALE_NAME, s.SALE_ID, SUM(bh.FCY_AMT) AS TotalSales
FROM banhang bh
JOIN staff s ON bh.SALE_ID = s.SALE_ID
JOIN branch b ON bh.STOREDID = b.STOREDID
GROUP BY YEAR(bh.TRANS_DATE), b.STOREDID, b.ADDRESS, s.SALE_NAME, s.SALE_ID
ORDER BY Year, b.STOREDID, TotalSales DESC;

-- Nhân viên bán hàng nào có tỷ lệ chiết khấu trả chậm (CHAMTRA) cao nhất theo từng năm?
SELECT 
	YEAR(bh.TRANS_DATE) AS Year,
	s.SALE_NAME, s.SALE_ID,
	AVG(bh.CHAMTRA) AS AverageDelayedDiscount
FROM banhang bh
JOIN staff s ON bh.SALE_ID = s.SALE_ID
GROUP BY YEAR(bh.TRANS_DATE), s.SALE_NAME, s.SALE_ID
ORDER BY Year, AverageDelayedDiscount DESC;



SELECT YEAR(bh.TRANS_DATE) AS Year, s.SALE_NAME, s.SALE_ID, s.HE_SO_LUONG, SUM(bh.FCY_AMT) AS TotalSales
FROM banhang bh
JOIN staff s ON bh.SALE_ID = s.SALE_ID
GROUP BY YEAR(bh.TRANS_DATE), s.SALE_NAME, s.SALE_ID, s.HE_SO_LUONG
ORDER BY Year, s.HE_SO_LUONG DESC, TotalSales DESC;


-- Tỷ giá hối đoái trung bình của mỗi loại tiền tệ theo từng tháng?
SELECT
	YEAR(Bussiness_date) AS Year, MONTH(Bussiness_date) AS Month, 
	CCY_Code, AVG(Exchange_RATE) AS AvgExchangeRate
FROM ty_gia
GROUP BY YEAR(Bussiness_date), MONTH(Bussiness_date), CCY_Code
ORDER BY Year, Month, CCY_Code;

select * from ty_gia

-- Tỷ giá hối đoái cao nhất và thấp nhất của mỗi loại tiền tệ theo từng năm?
SELECT YEAR(Bussiness_date) AS Year, CCY_Code, 
       MAX(EXCHANGE_RATE) AS MaxExchangeRate, 
       MIN(EXCHANGE_RATE) AS MinExchangeRate
FROM ty_gia
GROUP BY YEAR(Bussiness_date), CCY_Code
ORDER BY Year, CCY_Code;

-- Ngày có tỷ giá hối đoái cao nhất cho mỗi loại tiền tệ?
SELECT CCY_Code, Bussiness_date, EXCHANGE_RATE
FROM ty_gia t
WHERE EXCHANGE_RATE = (
    SELECT MAX(EXCHANGE_RATE)
    FROM ty_gia
    WHERE CCY_Code = t.CCY_Code
)
ORDER BY CCY_Code, Bussiness_date;

-- Ngày có sự thay đổi tỷ giá lớn nhất của mỗi loại tiền tệ trong năm?
WITH Changes AS (
    SELECT 
        CCY_Code, 
        Bussiness_date, 
        EXCHANGE_RATE,
        LAG(EXCHANGE_RATE) OVER (PARTITION BY CCY_Code ORDER BY Bussiness_date) AS PrevExchangeRate
    FROM ty_gia
)
SELECT 
    CCY_Code, 
    Bussiness_date, 
    EXCHANGE_RATE, 
    ABS(EXCHANGE_RATE - PrevExchangeRate) AS ChangeAmount
FROM Changes
WHERE YEAR(Bussiness_date) in (2019,2020)
ORDER BY ChangeAmount DESC;



WITH FirstLastDays AS (
    SELECT 
        CCY_Code, 
        Bussiness_date,
        EXCHANGE_RATE,
        ROW_NUMBER() OVER (PARTITION BY CCY_Code, YEAR(Bussiness_date), MONTH(Bussiness_date) ORDER BY Bussiness_date ASC) AS FirstDayRank,
        ROW_NUMBER() OVER (PARTITION BY CCY_Code, YEAR(Bussiness_date), MONTH(Bussiness_date) ORDER BY Bussiness_date DESC) AS LastDayRank
    FROM ty_gia
)
SELECT 
    CCY_Code, 
    YEAR(Bussiness_date) AS Year, 
    MONTH(Bussiness_date) AS Month,
    Bussiness_date,
    Exchange_RATE,
    CASE 
        WHEN FirstDayRank = 1 THEN 'FirstDay' 
        WHEN LastDayRank = 1 THEN 'LastDay' 
    END AS DayType
FROM FirstLastDays
WHERE FirstDayRank = 1 OR LastDayRank = 1
ORDER BY Year, Month, CCY_Code, DayType;


select 
	STOREDID
* from banhang

select * from branch
where ADDRESS like N'Hồ%'