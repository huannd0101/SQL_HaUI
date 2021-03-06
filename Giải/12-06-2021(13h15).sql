USE master
GO

DROP DATABASE QLKho 
GO

CREATE DATABASE QLKho 
GO

USE QLKho 
GO

CREATE TABLE Ton (
	MaVT CHAR(5) PRIMARY KEY,
	TenVT NVARCHAR(30),
	MauSac NVARCHAR(30),
	SoLuong INT,
	GiaBan MONEY,
	SoLuongT INT
)

CREATE TABLE Nhap (
	SoHDN CHAR(5),
	MaVT CHAR(5),
	SoLuongN INT,
	DonGiaN MONEY,
	NgayN DATE, 
	PRIMARY KEY(SoHDN, MaVT), 
	CONSTRAINT fk_nhap_ton FOREIGN KEY(MaVT) REFERENCES Ton (MaVT)
)

CREATE TABLE Xuat (
	SoHDX CHAR(5),
	MaVT CHAR(5),
	SoLuongX INT,
	NgayX DATE, 
	PRIMARY KEY(SoHDX, MaVT), 
	CONSTRAINT fk_xuat_ton FOREIGN KEY(MaVT) REFERENCES Ton (MaVT)
)

INSERT INTO Ton VALUES
('VT01', N'Vật tư 1', N'Xanh', 13, 120000, 4), 
('VT02', N'Vật tư 2', N'Đỏ', 14, 220000, 5), 
('VT03', N'Vật tư 3', N'Xanh', 15, 320000, 6), 
('VT04', N'Vật tư 4', N'Tím', 16, 420000, 7), 
('VT05', N'Vật tư 5', N'Vàng', 17, 520000, 8)

INSERT INTO Nhap VALUES 
('HDN01', 'VT01', 5, 120000, '2021-01-01'), 
('HDN02', 'VT02', 6, 220000, '2020-01-01'), 
('HDN03', 'VT03', 7, 320000, '2019-01-01') 

INSERT INTO Xuat VALUES
('HDX01', 'VT01', 1, '2021-01-02'),
('HDX02', 'VT02', 2, '2020-01-02'),
('HDX03', 'VT03', 3, '2019-01-02')

--Xem dữ liệu
SELECT * FROM Nhap
SELECT * FROM Xuat
SELECT * FROM Ton

--Câu 2:
GO
CREATE FUNCTION fn_cau2 (@ngayXuat DATE, @maVT CHAR(5))
RETURNS @table TABLE(MaVT CHAR(5), TenVT NVARCHAR(30), TienBan MONEY)
AS
BEGIN
	INSERT INTO @table
	SELECT Ton.MaVT, TenVT, SoLuongX * GiaBan
	FROM Ton INNER JOIN Xuat
	ON Ton.MaVT = Xuat.MaVT
	WHERE NgayX = @ngayXuat AND Ton.MaVT = @maVT
	RETURN
END

SELECT * FROM dbo.fn_cau2('2021-01-02', 'VT01')

--Câu 3:
GO
CREATE PROC p_cau3 (@soHDX CHAR(5), @soLuongX INT, @ngayX DATE, @maVT CHAR(5))
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM Ton WHERE MaVT = @maVT))
		BEGIN
			--K TỒN TẠI
			PRINT N'Mã vật tư không tồn tại'
			RETURN
		END
	ELSE 
		BEGIN
			INSERT INTO Xuat VALUES (@soHDX, @maVT, @soLuongX, @ngayX)
		END
END

--thực thi
--Không thành công
EXEC p_cau3 'HDX04', 21, '2021-01-03', 'VT00'
SELECT * FROM Xuat

-- thành công
EXEC p_cau3 'HDX04', 21, '2021-01-03', 'VT01'
SELECT * FROM Xuat


--Câu 4:
GO
CREATE TRIGGER tg_cau4 
ON Nhap 
FOR INSERT 
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM inserted INNER JOIN Ton ON inserted.MaVT = Ton.MaVT))
		BEGIN
			RAISERROR(N'Mã VT chưa có mặt trong bảng Ton', 16, 1)
			ROLLBACK TRAN
		END
	ELSE 
		BEGIN
			DECLARE @soLuong INT = (SELECT SoLuongN FROM inserted)		
			UPDATE Ton
			SET SoLuong = SoLuong + @soLuong
			WHERE MaVT = (SELECT MaVT FROM inserted)
		END
END

--THỰC THI
--thất bại
ALTER TABLE Nhap NOCHECK CONSTRAINT ALL
INSERT INTO Nhap VALUES ('HDN04', 'VT00', 5, 120000, '2021-01-01')
SELECT * FROM Nhap
SELECT * FROM Ton

--THÀNH CÔNG
ALTER TABLE Nhap NOCHECK CONSTRAINT ALL
INSERT INTO Nhap VALUES ('HDN04', 'VT01', 5, 120000, '2021-01-01')
SELECT * FROM Nhap
SELECT * FROM Ton