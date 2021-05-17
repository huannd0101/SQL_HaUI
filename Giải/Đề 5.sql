--ĐỀ 5
CREATE DATABASE QLKho
GO

USE QLKho
GO

CREATE TABLE VatTu (
	MaVT CHAR(5) PRIMARY KEY, 
	TenVT NVARCHAR(30), 
	SLCon INT
)

CREATE TABLE PhieuXuat (
	SoPX CHAR(5) PRIMARY KEY, 
	NgayXuat DATE, 
	HoTenKhach NVARCHAR(30)
)

CREATE TABLE HangXuat (
	SoPX CHAR(5), 
	MaVT CHAR(5), 
	DonGia MONEY, 
	SLBan INT, 
	PRIMARY KEY(SoPX, MaVT), 
	CONSTRAINT pk_px FOREIGN KEY (SoPX) REFERENCES PhieuXuat(SoPX), 
	CONSTRAINT pk_vt FOREIGN KEY (MaVT) REFERENCES VatTu(MaVT)
)

INSERT INTO VatTu VALUES
('VT01', N'Vật tư 1', 20), 
('VT02', N'Vật tư 2', 30), 
('VT03', N'Vật tư 3', 40)

INSERT INTO PhieuXuat VALUES 
('PX01', '2021-01-01', N'Khách hàng 1'), 
('PX02', '2021-05-01', N'Khách hàng 2'),
('PX03', '2021-10-01', N'Khách hàng 3')

INSERT INTO HangXuat VALUES
('PX01', 'VT01', 250000, 30), 
('PX01', 'VT02', 240000, 40), 
('PX01', 'VT03', 230000, 50), 
('PX02', 'VT01', 220000, 60), 
('PX03', 'VT01', 210000, 70)

SELECT * FROM VatTu
SELECT * FROM PhieuXuat
SELECT * FROM HangXuat

--Câu 2: tạo view
CREATE VIEW v_cau2
AS
SELECT PhieuXuat.SoPX, FORMAT(NgayXuat, 'dd-MM-yyyy') AS N'Ngày Xuất' , SUM(DonGia * SLBan) AS N'Tổng tiền'
FROM PhieuXuat INNER JOIN HangXuat
ON PhieuXuat.SoPX = HangXuat.SoPX
WHERE YEAR(NgayXuat) = YEAR(GETDATE())
GROUP BY PhieuXuat.SoPX, NgayXuat

--thực thi
SELECT * FROM v_cau2

--Câu 3: tạo proc
GO
CREATE PROC p_cau3 (@thang INT, @nam INT)
AS 
BEGIN
	DECLARE @tongSL INT
	SET @tongSL = (SELECT SUM(SLBan)
					FROM PhieuXuat INNER JOIN HangXuat
					ON PhieuXuat.SoPX = HangXuat.SoPX
					WHERE MONTH(NgayXuat) = @thang AND YEAR(NgayXuat) = @nam
					GROUP BY PhieuXuat.SoPX
					)
	DECLARE @notification NVARCHAR(100)
	SET @notification = N'Tổng số lượng vật tư xuất trong tháng ' + CONVERT(CHAR(2), @thang) 
						+ '- ' + CONVERT(CHAR(4), @nam) + N' là: ' + CONVERT(CHAR, @tongSL)

	PRINT @notification
END

--thực thi
EXEC p_cau3 1, 2021

--Câu 4: tạo trigger
GO
CREATE TRIGGER tg_cau4
ON HangXuat 
FOR INSERT, DELETE
AS
BEGIN
	DECLARE @action CHAR(1)
	SET @action = (CASE WHEN EXISTS (SELECT * FROM inserted)
						THEN 'I'
						WHEN EXISTS (SELECT * FROM deleted)
						THEN 'D'
					END)
	IF(@action = 'D')
		BEGIN
			DECLARE @slXoa INT = (SELECT SLBan FROM deleted)
			UPDATE VatTu
			SET SLCon = SLCon + @slXoa
			WHERE MaVT = (SELECT MaVT FROM deleted)
		END
	ELSE 
		BEGIN
			DECLARE @slBan INT = (SELECT SLBan FROM inserted)
			DECLARE @slCon INT = (SELECT SLCon FROM VatTu INNER JOIN inserted 
												ON VatTu.MaVT = inserted.MaVT)
			IF(@slBan <= @slCon)
				BEGIN
					UPDATE VatTu
					SET SLCon = SLCon - @slBan
					WHERE MaVT = (SELECT MaVT FROM inserted)
				END
			ELSE 
				BEGIN
					RAISERROR(N'Không đủ số lượng bán', 16, 1)
					ROLLBACK TRAN
				END
		END
END

--THỰC THI
--thêm thành công
INSERT INTO HangXuat VALUES ('PX02', 'VT02', 200000, 10)
SELECT * FROM VatTu
SELECT * FROM HangXuat
--thêm thất bại
INSERT INTO HangXuat VALUES ('PX02', 'VT02', 200000, 50)
SELECT * FROM VatTu
SELECT * FROM HangXuat
--xóa
DELETE HangXuat WHERE SoPX = 'PX01' AND MaVT = 'VT01'
SELECT * FROM VatTu
SELECT * FROM HangXuat