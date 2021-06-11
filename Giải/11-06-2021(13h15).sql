CREATE DATABASE QLKhachSan 
GO
USE master
GO
DROP DATABASE QLKhachSan
USE QLKhachSan 
GO

CREATE TABLE Khach (
	MaKhach CHAR(5) PRIMARY KEY,
	TenKhach NVARCHAR(30), 
	SoDT CHAR(15),  
	Email CHAR(30), 
	Diachi NVARCHAR(30)
)

CREATE TABLE Phong (
	MaPhong CHAR(5) PRIMARY KEY, 
	TenPhong NVARCHAR(30), 
	LoaiPhong NVARCHAR(30),  
	DonGia MONEY, 
	SoNguoi INT
)

CREATE TABLE HoaDon (
	SoHD CHAR(5) PRIMARY KEY, 
	MaKhach CHAR(5), 
	MaPhong CHAR(5), 
	SoNgay INT, 
	CONSTRAINT fk_hoaDon_khach FOREIGN KEY(MaKhach) REFERENCES Khach(MaKhach), 
	CONSTRAINT fk_hoaDon_phong FOREIGN KEY(MaPhong) REFERENCES Phong(MaPhong)
)

INSERT INTO Khach VALUES
('K01', N'Khách 1', '0987654321', 'huannd0101@gmail.com', N'Điện Biên'),
('K02', N'Khách 2', '0987654322', 'huannd01012@gmail.com', N'Hà Nội'),
('K03', N'Khách 3', '0987654323', 'huannd01013@gmail.com', N'Hải Dương')

INSERT INTO Phong VALUES
('P01', N'Phòng 1', N'VIP 1', 2000000, 2),
('P02', N'Phòng 2', N'VIP 1', 3000000, 3),
('P03', N'Phòng 3', N'VIP 2', 4000000, 2)

INSERT INTO HoaDon VALUES
('HD01', 'K01', 'P01', 2),
('HD02', 'K02', 'P01', 3),
('HD03', 'K03', 'P01', 4),
('HD04', 'K01', 'P02', 5),
('HD05', 'K01', 'P03', 6)

--XEM DỮ LIỆU
SELECT * FROM Khach
SELECT * FROM Phong
SELECT * FROM HoaDon

--Câu 2:
GO
CREATE FUNCTION fn_cau2 (@loaiPhong NVARCHAR(30), @soNgayThue INT)
RETURNS @table TABLE(MaKhach CHAR(5), TenKhach NVARCHAR(30), MaPhong CHAR(5), TenPhong NVARCHAR(30))
AS
BEGIN
	INSERT INTO @table
	SELECT Khach.MaKhach, TenKhach, Phong.MaPhong, TenPhong
	FROM Phong INNER JOIN HoaDon
	ON Phong.MaPhong = HoaDon.MaPhong
	INNER JOIN Khach 
	ON Khach.MaKhach = HoaDon.MaKhach
	WHERE LoaiPhong = @loaiPhong AND SoNgay = @soNgayThue
	RETURN 
END

--THỰC THI
SELECT * FROM dbo.fn_cau2 (N'VIP 1', 2)

--Câu 3:
GO
CREATE PROC p_cau3 (@soHD CHAR(5), @makhach CHAR(5), @tenPhong NVARCHAR(30), @soNgay INT)
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM Phong WHERE TenPhong = @tenPhong))
		BEGIN
			PRINT N'Tên phòng không tồn tại'
			RETURN
		END
	ELSE
		BEGIN
			DECLARE @maPhong CHAR(5) = (SELECT MaPhong FROM Phong WHERE TenPhong = @tenPhong)
			INSERT INTO HoaDon VALUES (@soHD, @makhach, @maPhong, @soNgay)
		END
END

--THỰC THI
--KHÔNG THÀNH CÔNG
EXEC p_cau3 'HD06', 'K01', N'Phòng 10', 6
SELECT * FROM Phong
SELECT * FROM HoaDon
--THÀNH CÔNG
EXEC p_cau3 'HD06', 'K01', N'Phòng 1', 6
SELECT * FROM Phong
SELECT * FROM HoaDon

--Câu 4:
GO
CREATE TRIGGER tg_cau4 
ON HoaDon
AFTER INSERT 
AS
BEGIN
	DECLARE @soNguoi INT = (SELECT SoNguoi FROM inserted INNER JOIN Phong ON inserted.MaPhong = Phong.MaPhong)
	IF(NOT EXISTS(SELECT * FROM inserted INNER JOIN Khach ON inserted.MaKhach = Khach.MaKhach))
		BEGIN
			RAISERROR(N'Mã khách không tồn tại', 16, 1)
			ROLLBACK TRAN
		END
	ELSE IF(NOT EXISTS(SELECT * FROM inserted INNER JOIN Phong ON inserted.MaPhong = Phong.MaPhong))
		BEGIN
			RAISERROR(N'Mã phòng không tồn tại', 16, 1)
			ROLLBACK TRAN
		END
	ELSE 
		BEGIN
			UPDATE Phong 
			SET SoNguoi  = SoNguoi + 1
			WHERE MaPhong = (SELECT MaPhong FROM inserted)
		END
END

--THỰC THI
--KHÔNG THÀNH CÔNG
ALTER TABLE HoaDon NOCHECK CONSTRAINT ALL
INSERT INTO HoaDon VALUES ('HD07', 'K07', 'P03', 6)
ALTER TABLE HoaDon NOCHECK CONSTRAINT ALL
INSERT INTO HoaDon VALUES ('HD07', 'K01', 'P07', 6)
SELECT * FROM Phong
SELECT * FROM HoaDon
--THÀNH CÔNG
ALTER TABLE HoaDon NOCHECK CONSTRAINT ALL
INSERT INTO HoaDon VALUES ('HD07', 'K01', 'P03', 6)
SELECT * FROM Phong
SELECT * FROM HoaDon