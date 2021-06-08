CREATE DATABASE QLSach2
GO

USE QLSach2
GO

CREATE TABLE TacGia (
	MaTG CHAR(5) PRIMARY KEY, 
	TenTG NVARCHAR(30), 
	SoLuongCo INT
)

CREATE TABLE NhaXB (
	MaNXB CHAR(5) PRIMARY KEY, 
	TenNXB NVARCHAR(30), 
	SoLuongCo INT
)

CREATE TABLE Sach (
	MaSach CHAR(5) PRIMARY KEY, 
	TenSach NVARCHAR(30), 
	MaNXB CHAR(5), 
	MaTG CHAR(5), 
	NamXB INT, 
	SoLuong INT, 
	DonGia MONEY, 
	CONSTRAINT fk_nxb FOREIGN KEY (MaNXB) REFERENCES NhaXB(MaNXB),
	CONSTRAINT fk_tg FOREIGN KEY (MaTG) REFERENCES TacGia(MaTG)
)

INSERT INTO TacGia VALUES
('TG01', N'Nguyễn Đình Huân', 20),
('TG02', N'Nguyễn Đình Huân 2', 30),
('TG03', N'Nguyễn Đình Huân 3 ', 40)

INSERT INTO NhaXB VALUES
('NXB01', N'Nhi Đồng', 10),
('NXB02', N'Thiếu niên', 15),
('NXB03', N'Tin tức', 20)

INSERT INTO Sach VALUES
('S01', N'Sách 01', 'NXB01', 'TG01', 2020, 11, 20000),
('S02', N'Sách 02', 'NXB02', 'TG01', 2019, 10, 21000),
('S03', N'Sách 03', 'NXB02', 'TG02', 2018, 9, 22000),
('S04', N'Sách 04', 'NXB02', 'TG02', 2021, 8, 23000),
('S05', N'Sách 05', 'NXB03', 'TG03', 2020, 7, 24000)

SELECT * FROM TacGia
SELECT * FROM NhaXB
SELECT * FROM Sach

-- CÂU 2: CREATE PROC
GO
CREATE PROC p_cau2 (@maSach CHAR(5), @tenSach NVARCHAR(30), @tenNXB NVARCHAR(30), @maTG CHAR(5), 
					@namXB INT, @soLuong INT, @donGia MONEY)
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM NhaXB WHERE TenNXB = @tenNXB))
		BEGIN
			PRINT N'Tên nhà xuất bản KHÔNG tồn tại'
			RETURN
		END
	ELSE 
		BEGIN
			DECLARE @maNXB CHAR(5) = (
				SELECT MaNXB FROM NhaXB WHERE TenNXB = @tenNXB
			)
			INSERT INTO Sach VALUES (@maSach, @tenSach, @maNXB, @maTG, @namXB, @soLuong, @donGia)
		END
END

--Thực thi
--không thành công
EXEC p_cau2 'S06', N'Sách 06', N'Nhi Đồng 1', 'TG01', 2021, 9, 100000
SELECT * FROM Sach
--thành công
EXEC p_cau2 'S06', N'Sách 06', N'Nhi Đồng', 'TG01', 2021, 9, 100000
SELECT * FROM Sach

--Câu 3: create fucntion
GO
CREATE FUNCTION fn_cau3 (@tenTG NVARCHAR(30))
RETURNS MONEY
AS
BEGIN
	DECLARE @tongTien MONEY
	SELECT @tongTien = (
		SELECT SUM(SoLuong * DonGia)
		FROM Sach	
	)
	RETURN @tongTien
END

--Thực thi
SELECT dbo.fn_cau3 (N'Nguyễn Đình Huân') AS N'Tổng tiền'

--Câu 4: CREATE TRIGGER
GO
CREATE TRIGGER tg_cau4 
ON Sach
FOR INSERT
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM inserted INNER JOIN NhaXB ON NhaXB.MaNXB = inserted.MaNXB))
		BEGIN 
			RAISERROR(N'Mã NXB chưa có mặt trong bảng NXB', 16, 1)
			ROLLBACK TRAN
		END
	ELSE 
		BEGIN
			UPDATE NhaXB
			SET SoLuongCo = SoLuongCo + (
				SELECT SoLuong FROM inserted
			)
			WHERE MaNXB = (SELECT MaNXB FROM inserted)
		END
END

--THỰC THI
--KHÔNG THÀNH CÔNG
ALTER TABLE Sach NOCHECK CONSTRAINT ALL
INSERT INTO Sach VALUES ('S07', N'Sách 07', 'NXB08', 'TG03', 2020, 7, 24000)
SELECT * FROM NhaXB
SELECT * FROM Sach

--THÀNH CÔNG
ALTER TABLE Sach NOCHECK CONSTRAINT ALL
INSERT INTO Sach VALUES ('S07', N'Sách 07', 'NXB02', 'TG03', 2022, 7, 14000)
SELECT * FROM NhaXB
SELECT * FROM Sach